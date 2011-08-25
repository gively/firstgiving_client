require "httparty"
require "firstgiving_client/donation"

module FirstGivingClient
  class DonationClient
    include HTTParty
    format :xml
    
    attr_accessor :application_key, :security_token, :use_sandbox
    
    def initialize(options = {})
      %w(application_key security_token use_sandbox).each do |field|
        self.send("#{field}=", options[field]) if options[field]
      end
    end
    
    def donate!(donation)
      result = self.class.post(donation_url("/donation/creditcard"), 
        :headers => auth_headers,
        :body => donation.to_params)
      donation_response(result)["transactionId"]
    end
    
    def donate_recurring!(donation)
      result = self.class.post(donation_url("/donation/recurringcreditcardprofile"), 
        :headers => auth_headers,
        :body => donation.to_params)
      donation_response(result)["recurringDonationProfileId"]
    end
    
    def valid_message?(message, signature)
      result = self.class.get(donation_url("/verify"),
        :headers => auth_headers,
        :query => { :message => message, :signature => signature })
      donation_response(result)["valid"] == "1"
    end
    
    protected
    
    def donation_response(result)
      result.parsed_response["firstGivingDonationApi"]["firstGivingResponse"]
    end
    
    def auth_headers
      { "JG_APPLICATIONKEY" => application_key, "JG_SECURITYTOKEN" => security_token }
    end
      
    def donation_url(path)
      if use_sandbox
        "https://api.firstgiving.com#{path}"
      else
        "http://usapisandbox.fgdev.net#{path}"
      end
    end
  end
end