# RailsAdmin AuthorizedFields

This gem adds ability to setup authorization rules for fields in a simple way.

## Installation

Add this line to your application's Gemfile:

    gem 'rails_admin_authorized_fields'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_authorized_fields

## Configuration

Create ```initilializers/rails_admin_authorized_fields.rb```:

    RailsAdminAuthorizedFields.configure do |config|
      config.default_rule = proc { bindings[:view]._current_user.has_role?( :admin ) }
    end

```default_rule``` used when either ```authorized_fields``` or ```unauthorized_fields``` section included but rules for some fields are not specified.

## Usage

Just add ```authorized_fields``` section to your model with specified rules:

    rails_admin do
      authorized_fields( {
        [ :enabled, :is_default, :text_slug ] => proc { bindings[:view]._current_user.has_role?( :admin ) },
        [ :domain ] => proc { !bindings[:view]._current_user.has_role?( :manager ) },
      } )

      field :enabled
      field :name
      field :domain
      field :is_default
      field :text_slug
    end

You can also use ```unauthorized_fields``` section in opposite of ```authorized_fields```. All rules will be checked.

    rails_admin do
      unauthorized_fields( {
        [ :enabled, :is_default, :text_slug ] => proc { bindings[:view]._current_user.has_role?( :manager ) },
      } )

      field :enabled
      field :name
      field :domain
      field :is_default
      field :text_slug
    end

Note: all fields are not ```authorized``` by default if any rules present.

TODO: just a small changes needed to make ```authorized_fields``` section overridable in subsection (list, edit)

## Changelog

1.2.0 - added default authorization rule

1.0.0 - changed default authorized logic. In 0.0.3 all fields were authorized by default. In 1.0.0 fields unauthorized when either ```authorized_fields``` or ```unauthorized_fields``` sections are present.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
