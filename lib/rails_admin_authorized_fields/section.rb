module RailsAdminAuthorizedFields
  module AuthorizedFieldsSection
    def initialize(parent)
      @allow_rules, @deny_rules = {}, {}

      super(parent)
    end

    def authorized_fields(rules)
      rules.each do |fields, rule|
        fields = [fields].flatten

        fields.each do |name|
          name = name.to_sym
          @allow_rules[name] ||= []
          @allow_rules[name] << rule
        end
      end
    end

    def unauthorized_fields(rules)
      rules.each do |fields, rule|
        fields = [fields].flatten

        fields.each do |name|
          name = name.to_sym
          @deny_rules[name] ||= []
          @deny_rules[name] << rule
        end
      end
    end

    def visible_fields
      return super if bindings.nil?

      super.select do |field|
        rules = field.section.field_authorization_rules(field.name)

        if field.section.plugin_included?
          authorized = rules[:allow].any? || rules[:deny].any?

          unless authorized
            default_rule = RailsAdminAuthorizedFields.config.default_rule
            authorized = instance_eval(&default_rule) if default_rule.is_a?( Proc )
          end

          rules[:allow].each do |rule|
            authorized &= instance_eval(&rule)
          end

          rules[:deny].each do |rule|
            authorized &= !instance_eval(&rule)
          end

        else
          authorized = true
        end

        authorized
      end
    end

    protected

      def plugin_included?(descendant = nil)
        result = @allow_rules.any? || @deny_rules.any?

        return result if result
        return false if @parent.nil?
        return false if self == descendant

        @parent.plugin_included?(self)
      end

      def field_authorization_rules(name)
        {
          allow: extract_rules(name, :allow_rules),
          deny: extract_rules(name, :deny_rules),
        }
      end

      def extract_rules(name, kind, descendant = nil)
        rules = instance_variable_get(:"@#{kind}")

        return rules[name] || [] if rules.any?
        return [] if @parent.nil?
        return [] if self == descendant

        @parent.extract_rules(name, kind, self)
      end

  end
end

module RailsAdmin
  module Config
    module Sections
      # Configuration of the show view for a new object
      class Base
        prepend RailsAdminAuthorizedFields::AuthorizedFieldsSection
      end
    end
  end
end
