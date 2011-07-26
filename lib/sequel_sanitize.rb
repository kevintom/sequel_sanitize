module Sequel
  module Plugins
    # The Sanitize plugin basically does a 'before_filter' on 
    # specified fields, if no sanitizer is specified the default 
    # one is used
    #
    module Sanitize
      # Plugin configuration
      def self.configure(model, opts={})
        model.sanitize_options = opts
        model.sanitize_options.freeze
        model.class_eval do
          sanitize_options[:fields].each do |f|
            define_method("#{f}=") do |value|
              sanitizer = self.class.sanitize_options[:field_sanitize][f]
              do_downcase = self.class.sanitize_options[:field_downcase][f]
              sanitized = sanitizer.call(value) if sanitizer.respond_to?(:call)
              sanitized ||= self.send(sanitizer, value) if sanitizer
              sanitized = sanitized.downcase if do_downcase and sanitized.respond_to?(:downcase)
              super(sanitized)
            end
          end
        end
      end

      module ClassMethods
        attr_reader :sanitize_options
        # Propagate settings to the child classes
        # @param [Class] Child class
        def inherited(klass)
          super
          klass.sanitize_options = self.sanitize_options.dup
        end

        def sanitize_options=(options)
          fields = options[:fields]
          if fields.nil? || !fields.is_a?(Array) || fields.empty?
            raise ArgumentError, ":fields must be a non-empty array"
          end
          options[:fields] = fields.uniq.compact
          sanitizer = options[:sanitizer]
          if sanitizer && !sanitizer.is_a?(Symbol) && !sanitizer.respond_to?(:call)
            raise ArgumentError, "If you provide :sanitizer it must be Symbol or callable."
          end
          sanitizer_to_be_called = sanitizer.nil? ? :sanitize_field : sanitizer
          do_downcase = options[:downcase].class == TrueClass
          field_sanitize_map = {}
          field_downcase_map = {}
          options[:fields].each do |f|
            field_sanitize_map[f.to_sym] = sanitizer_to_be_called
            field_downcase_map[f.to_sym] = do_downcase
          end
          @sanitize_options ||= {}
          @sanitize_options[:fields] ||= []
          @sanitize_options[:field_sanitize] ||= {}
          @sanitize_options[:field_downcase] ||= {}
          @sanitize_options[:fields].concat(options[:fields])
          @sanitize_options[:fields].uniq!
          @sanitize_options[:fields].compact!
          @sanitize_options[:field_sanitize].merge!(field_sanitize_map)
          @sanitize_options[:field_downcase].merge!(field_downcase_map)
        end
      end

      module InstanceMethods
        private
        def sanitize_field(value)
          sanitized_value = value.strip if value.respond_to?(:strip)
          sanitized_value
        end
      end # InstanceMethods
    end # Sanitize
  end # Plugins
end # Sequel