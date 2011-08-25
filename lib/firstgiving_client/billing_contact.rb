require "firstgiving_client/param_convertible"

module FirstGivingClient
  class BillingContact
    include ParamConvertible
  
    param_accessor :optional, :title => "billToTitle", :middle_name => "billToMiddleName",
      :address_line2 => "billToAddressLine2", :address_line3 => "billToAddressLine3",
      :state => "billToState", :phone => "billToPhone"
      
    param_accessor :required, :first_name => "billToFirstName", :last_name => "billToLastName",
      :address_line1 => "billToAddressLine1", :city => "billToCity",
      :zip => "billToZip", :country => "billToCountry", :email => "billToEmail"
  end
end