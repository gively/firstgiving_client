require 'rack'
require 'webmock'
require 'active_support/core_ext'

module FirstGivingClient
  class FakeDonationAPI
    extend WebMock::API
    
    def self.call(env)
      request = Rack::Request.new(env)
      
      body = <<-EOM
      <?xml version=\"1.0\"?>
      <firstGivingDonationApi>
        <firstGivingResponse>
          <transactionId>#{Time.now.to_i}</transactionId>
        </firstGivingResponse>
      </firstGivingDonationApi>
      EOM
      
      [200, {}, [body]]
    end
    
    def self.setup_stubs!
      stub_request(:post, %r{^#{DonationClient::PRODUCTION_URL}/donation/creditcard}).to_rack(FakeDonationAPI)
      stub_request(:post, %r{^#{DonationClient::SANDBOX_URL}/donation/creditcard}).to_rack(FakeDonationAPI)
    end
    
    def self.setup_client!
      Tipjar::Application.guidestar_client.login = self.login
      Tipjar::Application.guidestar_client.password = self.password
    end
  end
end