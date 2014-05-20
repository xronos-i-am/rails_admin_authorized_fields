# RailsAdmin AuthorizedFields

This gem adds ability to setup authorization rules for fields in a simple way.

## Installation

Add this line to your application's Gemfile:

    gem 'rails_admin_authorized_fields'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_authorized_fields

## Usage

Just add ```authorized_fields``` section to your model with specified rules:

    rails_admin do
      authorized_fields( {
        [ :enabled, :is_default, :text_slug ] => Proc.new { bindings[:view]._current_user.has_role?( :admin ) },
        [ :domain ] => Proc.new { !bindings[:view]._current_user.has_role?( :manager ) },
      } )

      field :enabled
      field :name
      field :domain
      field :is_default
      field :text_slug
    end

TODO: just a small changes needed to make ```authorized_fields``` section overridable in subsection (list, edit)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
