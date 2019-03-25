# StringEnum

Gem provide ability to use enum of active record with string field at DB and store available values at config(yml file)

@todo add description, tests

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'string_enum'
```

And then execute:

    $ bundle

    $ rails g string_enum:install

## Usage

app/models/post.rb
```ruby
class Post < ApplicationRecord
  enumerate :status
  ....
end
```

config/models.yml
``` yaml
# YAML
post:
  statuses:
    - draft
    - published
    - archived
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/string_enum. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
