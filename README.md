# HasMoreSecureToken

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/has_more_secure_token`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `has_more_secure_token` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add has_more_secure_token

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install has_more_secure_token

Finally, add this to your `app/models/application_record.rb`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  include HasMoreSecureToken

  # ...
end
```

Note: HasMoreSecureToken was developed and tested only with PostgreSQL (major versions 12, 14, and 15).

## Usage

To use time-safe lookups with `has_secure_token`, we specify a `find_by_digest` with the digest algorithm we wish to use:
```ruby
class User < ApplicationRecord
  has_secure_token :password_reset_token, find_by_digest: 'sha256'
end
```
Doing so will override the `find_by_{token-name}` and `find_by_{token-name}!` methods (`find_by_password_reset_token` and `find_by_password_reset_token!` in the example above) that perform secure finds.

For example, if we now need to locate a User record by a token, we use:
```ruby
# Read a token from somewhere...
token = params[:password_reset_token]

User.find_by_password_reset_token(token) # => #<User:0x0000...>
```
And this will produce the following database query:
```ruby
  User Load (1.9ms)  SELECT "users".* FROM "users" WHERE digest("users"."password_reset_token", 'SHA256') = $1 LIMIT $2  [["password_reset_token", "<32 bytes of binary data>"], ["LIMIT", 1]]
```

As a nice side-effect, since a binary representation of the digest is used, Rails omits the exact values from our logs (regardless of whether our log filters are configured to match the name of the attribute).

### Improving Performance with Indices

HasMoreSecureToken uses binary hashes directly rather than a hex representation, so we can define an index to speed up lookups for the above example as follows:
```ruby
enable_extension 'pgcrypto' # required for `digest(...)` if not already enabled

create_table :users do |t|
  # We include a unique index to ensure no duplicate tokens are generated
  t.binary :password_reset_token, null: false, index: { unique: true }

  t.index "digest(password_reset_token, 'SHA256')",
          name:  'index_users_on_password_reset_token_digest',
          using: :hash # recommended for PG12 and newer
end
```
Since we are only concerned with the equality (`=`) operator, using a HASH index will provide fast lookups without revealing timing information in the same way a BTREE index might.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mintyfresh/has_more_secure_token. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mintyfresh/has_more_secure_token/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HasMoreSecureToken project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mintyfresh/has_more_secure_token/blob/main/CODE_OF_CONDUCT.md).
