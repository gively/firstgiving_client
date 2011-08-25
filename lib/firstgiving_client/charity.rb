require "httparty"

module FirstGivingClient
  class Charity
    include HTTParty
    
    base_uri "http://graphapi.firstgiving.com/v1"
    format :xml
    
    CHARITY_FIELDS = [:organization_uuid, :organization_name, :organization_alias, :government_id,
      :address_line_1, :address_line_2, :address_line_3, :address_line_full, :city, :region,
      :postal_code, :country, :address_full, :phone_number, :url, :category_code, :latitude,
      :longitude]
    
    attr_accessor *CHARITY_FIELDS
    
    def self.find_by_government_id(government_id)
      norm_id = government_id.to_s.gsub(/\D/, '')
    
      payload = get_payload("/list/organization", :query => { :q => "government_id:#{norm_id}" })
      payload && new(payload["key_0"])
    end
    
    def self.find_by_organization_uuid(uuid)
      payload = get_payload("/object/organization/#{uuid}")
      payload && new(payload)
    end
    
    def initialize(attributes={})
      attributes.each do |key, value|
        next unless CHARITY_FIELDS.include?(key.to_sym)
        send("#{key}=", value)
      end
    end
    
    private
    def self.get_payload(*args)
      payload = get(*args)["payload"]
      payload = payload["payload"] while payload && payload.has_key?("payload")
      
      payload
    end
  end
end