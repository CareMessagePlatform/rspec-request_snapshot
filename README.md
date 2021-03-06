# Rspec::RequestSnapshot

Gold master testing for RSpec API request specs. Make sure API behavior is not changing by taking and storing a snapshot from an API response on a first run and check if they match on next spec runs.

By default, snapshots are stored under `spec/fixtures/snapshots` and should be code reviewed as well. The syntax is inspired by Jest.

References:

* [Gold Master Testing article by CodeClimate](https://codeclimate.com/blog/gold-master-testing/)
* [Jest Snapshot Testing](https://jestjs.io/docs/en/snapshot-testing)

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

  # The json attributes that ignore order when comparing nodes
  # Default value is []
  config.request_snapshots_ignore_order = %w(array_node)

  # The default format to use, other formats must be specified using the :format option
  # Default value is :json
  config.request_snapshots_default_format = :json
end
```

### Snapshot files

On the first run, the `match_snapshot` matcher will always return success and it will store a snapshot file. On the next runs, it will compare the response with the file content.

If you need to replace snapshots, run the specs with:

    REPLACE_SNAPSHOTS=true bundle exec rspec

If you only need to add, remove or replace data without replacing the whole snapshot:

    CONSERVATIVE_UPDATE_SNAPSHOTS=true bundle exec rspec

**Note:** Conservative update will not work along with ignore_order option. It should only be used when there is
no major changes in the snapshots that will be updated.

If you want tests to fail in case a snapshot file does not exist (ie: when running on a CI):

    BLOCK_CREATE_SNAPSHOTS=true bundle exec rspec

### Matcher

```ruby
# Stores snapshot under spec/fixtures/snapshots/api/resources_index.json
expect(response.body).to match_snapshot("api/resources_index")

# Using plain text instead of parsing JSON
expect(response.body).to match_snapshot("api/resources_index", format: :text)
```

#### Matcher options

##### dynamic_attributes

Using `dynamic_attributes` inline allows to ignore attributes for a specific snapshot.
This is useful to ignore changing attributes, like `id` or `created_at`.
Notice that **all** nodes matching those (nested or not) will be ignored. Usage:

```ruby
# Defining specific test dynamic attributes
expect(response.body).to match_snapshot("api/resources_index", dynamic_attributes: %w(confirmed_at relation_id))
```

##### dynamic_attributes with regex

Sometimes you don't want to fully ignore an attribute. For example, you want to make sure
that `generated_id` is present and following a given pattern, but that attribute can change
randonly, use `dynamic_attributes` with object/regex notation:

```ruby
# Example generated_id: ABC-001
expect(response.body).to match_snapshot("api/resources_index", dynamic_attributes: [{ generated_id: /^\w{3}-\d{3}$/ }])
```

**Note:** Partial matches are also possible, so use the start/end of line characters for a strict match

##### ignore_order

It is possible to use the `ignore_order` inline option to mark which array nodes are unsorted and that elements position
should not be taken into consideration.

```ruby
# Ignoring order for certain arrays (this will ignore the ordering for the countries array inside the json response)
expect(response.body).to match_snapshot("api/resources_index", ignore_order: %w(countries))
```

**Note:** If you are using `ignore_order` for arrays of objects/hashes (ie: `[{name: "name", value: "value"}, ...]`),
it won't perform well depending on the array and hash size (number of keys)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CareMessagePlatform/rspec-request_snapshot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
