require "httparty"
require "firstgiving_client/donation"

module FirstGivingClient
  class DonationClient
    class RemoteException < Exception
      attr_accessor :friendly_message, :error_target, :acknowledgement
      
      def inspect
        "#<RemoteException from FirstGiving: #{message} (friendly_message: #{friendly_message}, target: #{error_target}, ack: #{acknowledgement}>"
      end
    end
        
    class Response
      attr_reader :client, :http_response, :environment, :signature, :execution_time, :payload
    
      def initialize(client, http_response)
        @client        = client
        @http_response = http_response
        
        @environment    = http_response.headers["Jg-Environment"]
        @signature      = http_response.headers["Jg-Response-Signature"]
        @execution_time = http_response.headers["Jg-Execution-Time"].to_i
        
        @payload = http_response.parsed_response["firstGivingDonationApi"]["firstGivingResponse"]
      end
      
      def success?
        http_response.code >= 200 && http_response.code < 300
      end
      
      def error?
        !success?
      end
      
      def exception
        return nil unless error?
        
        exc = RemoteException.new(payload["verboseErrorMessage"])
        
        exc.friendly_message = payload["friendlyErrorMessage"]
        exc.error_target     = payload["errorTarget"]
        exc.acknowledgement  = payload["acknowledgement"]
        
        return exc
      end
      
      def ensure_success!
        raise exception if error?
      end
      
      def valid?
        client.valid_message?(http_response.body, signature)
      end
    end
    
    class DonateResponse < Response
      attr_reader :transaction_id
    
      def initialize(client, http_response)
        super(client, http_response)
        
        @transaction_id = payload["transactionId"]
      end
    end
    
    class DonateRecurringResponse < Response
      attr_reader :recurring_donation_profile_id
      
      def initialize(client, http_response)
        super(client, http_response)
        
        @recurring_donation_profile_id = payload["recurringDonationProfileId"]
      end
    end
    
    include HTTParty
    format :xml
    
    PRODUCTION_URL = "https://api.firstgiving.com"
    SANDBOX_URL = "http://usapisandbox.fgdev.net"
    
    attr_accessor :application_key, :security_token
    
    def initialize(url, options = {})
      @url = url
      %w(application_key security_token).each do |field|
        value = options[field] || options[field.to_sym]
        self.send("#{field}=", value) if value
      end
    end
    
    def donate!(donation)
      result = self.class.post(donation_url("/donation/creditcard"), 
        :headers => auth_headers,
        :body => donation.to_params)

      resp = DonateResponse.new(self, result)
      resp.ensure_success!
      resp
    end
    
    def donate_recurring!(donation)
      result = self.class.post(donation_url("/donation/recurringcreditcardprofile"), 
        :headers => auth_headers,
        :body => donation.to_params)
        
      resp = DonateRecurringResponse.new(self, result)
      resp.ensure_success!
      resp
    end
    
    def valid_message?(message, signature)
      result = self.class.get(donation_url("/verify"),
        :headers => auth_headers,
        :query => { :message => message, :signature => signature })
        
      donation_response(result)["valid"] == "1"
    end
    
    protected
    
    def donation_response(result)
      resp = result.parsed_response["firstGivingDonationApi"]["firstGivingResponse"]
      
      if result.code < 200 || result.code >= 400
        exc = RemoteException.new(resp["verboseErrorMessage"])
        exc.friendly_message = resp["friendlyErrorMessage"]
        exc.error_target = resp["errorTarget"]
        exc.acknowledgement = resp["acknowledgement"]
        raise exc
      end
      
      return resp
    end
    
    def auth_headers
      { "JG_APPLICATIONKEY" => application_key, "JG_SECURITYTOKEN" => security_token }
    end
      
    def donation_url(path)
      "#{@url}#{path}"
    end
  end
end