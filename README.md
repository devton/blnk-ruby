# This gem is under development, don't use in production

# Blnk

Easy way to use the blnkfinance.com API in ruby

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add blnk

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install blnk

## TODO

- [x] Create Ledger
- [x] Find Ledger
- [x] List Ledgers
- [x] Search Ledgers
- [x] Create Balances
- [x] Find Balance
- [x] Search Balances
- [x] Create Transaction
- [ ] Multiple sources / destinations Transaction
- [ ] Refund Transaction
- [ ] Commit inflight Transaction
- [ ] Void inflight Transaction
- [x] Find Transaction
- [x] Search Transactions
- [ ] Handler notifications
- [ ] Create Balance Monitor
- [ ] Find Balance Monitor
- [ ] Update Balance Monitor
- [ ] Backup endpoint
- [ ] Backup to S3 endpoint
- [ ] Add Search Contract schema for each resource using they own search attributes
- [ ] Search Result should convert document resul into resource class
- [x] Use Dry Monads to get success / failure output
- [x] Use Dry Validation to validate inputs
- [ ] Use Dry Schema instead OpenStruct to handle with resource attributes
- [ ] Use Dry Configuration to better config DSL

## Usage

```ruby
transaction = Blnk::Transaction.find 'transaction_id'

require 'blnk'

# client config

Blnk.address = '192.168.2.7:5001'
Blnk.secret_token = 'your_strong_secret_key'
Blnk.search_api_key = Blnk.secret_token

# Ledgers

ledger = Blnk::Ledger.create(name: 'foobar')
ledger = Blnk::Ledger.find 'ledger_id'
ledgers = Blnk::Ledger.all

ledgers = Blnk::Ledger.search(q: '*')

# Balances
balance = Blnk::Balance.find 'balance_id'
balance = Blnk::Balance.create(ledger_id: 'ledger_id', currency: 'USD')

balances = Blnk::Balance.search(q: '*')

# Transactions
transaction = Blnk::Transaction.find 'transaction_id'
transaction = Blnk::Transaction.create(
  amount: 75,
  reference: 'ref_005',
  currency: 'BRLX',
  precision: 100,
  source: '@world',
  destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
  description: 'For fees',
  allow_overdraft: true
)

transaction = Blnk::Transaction.search q: '*'
```

## Result

All methods return a Dry::Monad::Result, so you can use ```.failure?``` to check if method was executed and returned a failure (can be validation or a server error). ```.success?``` to check if method was executed with successful and access the data from the failure or successful result using ```.value!```. You can check on the dry-monad gem to see other options on Result.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/devton/blnk-ruby

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
