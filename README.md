# Rspec::RequestSnapshot

Gold master testing for RSpec API request specs. Make sure API behavior is not changing by taking and storing a snapshot from an API response on a first run and check if they match on next spec runs.

By default, snapshots are stored under `spec/fixtures/snapshots` and should be code reviewed as well. The syntax is inspired by Jest.

References:
- [Gold Master Testing article by CodeClimate](https://codeclimate.com/blog/gold-master-testing/)
- [Jest Snapshot Testing](https://jestjs.io/docs/en/snapshot-testing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-request_snapshot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-request_snapshot

## Usage

### Configuration

```ruby
RSpec.configure do |config|
  # The place where snapshots will be stored
  # Default value is spec/fixtures/snapshots
  config.request_snapshots_dir = "spec/fixtures/snapshots"

  # The json attributes that you want to ignore when comparing snapshots
  # Default value is [id, created_at, updated_at]
  config.request_snapshots_dynamic_attributes = %w(id created_at updated_at)
end
```

### Snapshot files

On the first run, the `match_snapshot` matcher will always return success and it will store a snapshot file. On the next runs, it will compare the response with the file content.

If you need to replace snapshots, run the specs with:

    REPLACE_SNAPSHOTS=true bundle exec rspec

### Matcher

```ruby
# Stores snapshot under spec/fixtures/snapshots/api/resources_index.json
expect(response.body).to match_snapshot("api/resources_index")

# Using plain text instead of parsing JSON
expect(response.body).to match_snapshot("api/resources_index", format: :text)

# Defining specific test dynamic attributes
expect(response.body).to match_snapshot("api/resources_index", dyanmic_attributes: %w(confirmed_at relation_id))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CareMessagePlatform/rspec-request_snapshot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
