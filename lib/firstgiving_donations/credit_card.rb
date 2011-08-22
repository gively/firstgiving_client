require "firstgiving_donations/param_convertible"

module FirstGivingDonations
  class CreditCard
    include ParamConvertible

    param_accessor :required, :number => "ccNumber", :type => "ccType", 
      :expiration_year => "ccExpDateYear", :expiration_month => "ccExpDateMonth", 
      :validation_number => "ccCardValidationNum"
    
    VALID_TYPES = %w(VI MC DI AX)
        
    def type=(new_type)
      if new_type.nil?
        @type = nil
      else      
        norm_type = new_type.to_s.upcase.strip
        
        unless VALID_TYPES.include? norm_type
          raise ArgumentError.new("Invalid credit card type #{norm_type.inspect}.  Valid types are: #{VALID_TYPES.join(", ")}")
        end
  
        @type = norm_type
      end
    end
    
    def expiration_month=(exp_month)
      if exp_month.nil?
        @expiration_month = nil
      else
        int_month = exp_month.to_i
        
        unless int_month >= 1 && int_month <= 12
          raise ArgumentError.new("Invalid expiration month #{int_month.inspect}.")
        end
        
        @expiration_month = sprintf("%02d", int_month)
      end
    end
    
    def expiration_year=(exp_year)
      if exp_year.nil?
        @expiration_year = nil
      else
        int_year = exp_year.to_i % 100
        @expiration_year = sprintf("%02d", int_year)
      end
    end
  end
end