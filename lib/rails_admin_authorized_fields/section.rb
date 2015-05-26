module RailsAdminAuthorizedFields
  module AuthorazedFieldsSection
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
      return super if @allow_rules.empty? && @deny_rules.empty?

      super.select do |field|
        rules = field.section.field_authorization_rules(field.name)

        authorized = rules[:allow].any? || rules[:deny].any?

        rules[:allow].each do |rule|
          authorized &= instance_eval(&rule)
        end

        rules[:deny].each do |rule|
          authorized &= !instance_eval(&rule)
        end

        authorized
      end
    end

    protected

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
        prepend RailsAdminAuthorizedFields::AuthorazedFieldsSection
      end
    end
  end
end
