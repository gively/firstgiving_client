module FirstGivingClient
  module ParamConvertible
    def self.included(base)
      base.class_exec do       
        class << self
          attr_accessor :required_params, :optional_params
        end
      end
    
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end
  
    module ClassMethods
      def param_accessor(kind, params)
        case kind
        when :required
          @required_params ||= {}
          @required_params.update params
        when :optional
          @optional_params ||= {}
          @optional_params.update params
        else
          raise ArgumentError.new("First argument to param_accessor must be :optional or :required")
        end

        attr_accessor(*params.keys)        
      end
    end
    
    module InstanceMethods
      def attributes=(attributes)
        required = self.class.required_params || {}
        optional = self.class.optional_params || {}
        
        (required.keys + optional.keys).each do |key|
          if attributes.has_key?(key)
            self.send("#{key}=", attributes[key])
          end
        end
      end
    
      def to_params
        params = {}
        
        required = self.class.required_params || {}
        required.each do |field, param|
          params[param] = self.send(field)
        end
        
        optional = self.class.optional_params || {}
        optional.each do |field, param|
          value = self.send(field)
          params[param] = value unless value.blank?
        end
        
        params
      end
    end
  end
end