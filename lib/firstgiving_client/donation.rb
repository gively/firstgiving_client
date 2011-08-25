require "firstgiving_client/param_convertible"
require "firstgiving_client/credit_card"
require "firstgiving_client/billing_contact"

module FirstGivingClient
  class Donation
    include ParamConvertible

    attr_accessor :credit_card, :billing_contact, :amount
    param_accessor :required, :remote_addr => "remoteAddr", :charity_id => "charityId",
      :description => "description"
   
    param_accessor :optional, :event_id => "eventId", :fundraiser_id => "fundraiserId", 
      :order_id => "orderId", :report_donation_to_tax_authority => "reportDonationToTaxAuthority", 
      :personal_identification_number => "personalIdentificationNumber", 
      :message => "donationMessage", :honor_memory_name => "honorMemoryName"
      
    def initialize
      @credit_card = CreditCard.new
      @billing_contact = BillingContact.new
    end
      
    def to_params
      params = super
      params["amount"] = amount.format(:symbol => false)
      params["currencyCode"] = amount.currency_as_string

      params.update credit_card.to_params
      params.update billing_contact.to_params
      
      params
    end
  end
  
  class RecurringDonation < Donation
    param_accessor :required, :billing_descriptor => "billingDescriptor", 
      :recurring_billing_frequency => "recurringBillingFrequency", 
      :recurring_billing_term => "recurringBillingTerm"
  end
end