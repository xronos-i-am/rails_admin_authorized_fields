module RailsAdminAuthorizedFields
  module AuthorazedFieldsSection
    attr_accessor :authorization_rules

    def initialize(parent)
      @authorization_rules = {}

      super(parent)
    end

    def authorized_fields(rules)
      rules.each do |fields, rule|
        fields = [ fields ].flatten

        fields.each do |name|
          name = name.to_sym
          @authorization_rules[ name ] ||= []
          @authorization_rules[ name ] << rule
        end
      end
    end

    def field_authorization_rules( name )
      return @authorization_rules[ name ] || [] if @authorization_rules.any?
      return [] if self.parent.nil?
      parent.field_authorization_rules( name )
    end

    def visible_fields
      super.select do |field|
        authorized = true

        rules = field.section.field_authorization_rules( field.name )

        rules.each do |rule|
          authorized &= instance_eval( &rule )
        end

        authorized
      end
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

