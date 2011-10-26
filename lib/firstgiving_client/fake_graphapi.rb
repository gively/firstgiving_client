require 'rack'
require 'webmock'
require 'active_support/core_ext'

module FirstGivingClient
  class FakeGraphAPI
    extend WebMock::API
    
    def self.call(env)
      request = Rack::Request.new(env)
      
      body = "<?xml version=\"1.0\"?>\n" + case request.path
      when %r{^/v1/object/organization/(\d+)}
        ein = $1
        "<payload><payload><organization_uuid>#{ein}</organization_uuid></payload></payload>"
      when %r{^/v1/list/organization}
        field, value = request.params["q"].split(':')
        "<payload><payload><key_0><organization_uuid>#{value}</organization_uuid></key_0></payload></payload>"
      end
      
      [200, {}, [body]]
    end
    
    def self.setup_stubs!
      stub_request(:get, %r{^http://graphapi.firstgiving.com/}).to_rack(FakeGraphAPI)
    end
    
    def self.setup_client!
      Tipjar::Application.guidestar_client.login = self.login
      Tipjar::Application.guidestar_client.password = self.password
    end
  end
end