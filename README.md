# Blnk

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/blnk`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO:
- Client
- Create Ledger
- Find Ledger
- Create Balances
- Find Balances
- Create Transactions
- Find Transactions
- Do Search

## Configuration

```
Blnk.address = 'localhost:4444'
Blnk.secret_token = 'secret_token'
Blnk.search_api_key = 'secret_api_key'
```


## Ledger usage

```
ledger = Blnk::Ledger.new(name: 'ledger_name', metadata: { customer_id: 'mycustomerid' })
ledger.save


ledger = Blnk::Ledger.create(name: 'ledger_name', metadata: { customer_id: 'mycustomerid' })

ledger = Blnk::Ledger.find('ledger_id')
```

## Creating a transaction

```
client.create_transaction(destination: 'bal_ref_id', source: '@world', allow_overdraft: true, inflight: false)
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blnk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
