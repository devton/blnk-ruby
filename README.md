# This gem is under development, don't use in production

# Blnk

Easy way to use the blnkfinance.com API in ruby

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add blnk

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install blnk

## Usage

TODO:
- [x] Create Ledger
- [x] Find Ledger
- [x] List Ledgers
- [ ] Search Ledgers
- [x] Create Balances
- [x] Find Balance
- [ ] Search Balances
- [ ] Create Transaction
- [ ] Find Transaction
- [ ] Search Transactions

## Usage

```ruby
require 'blnk'

# client config

Blnk.address = '192.168.2.7:5001'
Blnk.secret_token = 'your_strong_secret_key'
Blnk.search_api_key = Blnk.secret_token

# ledgers integration

ledger = Blnk::Ledger.create(name: 'foobar')
ledger = Blnk::Ledger.find 'ledger_id'
ledgers = Blnk::Ledger.all

# search not implemented yet
ledgers = Blnk::Ledger.search(
  q: 'USD',
  filter_by: 'balances > 1400', 
  sort_by: 'created_at:desc', 
  page: 1, 
  per_page: 50
)


# Balance integrations
balance = Blnk::Balance.find 'balance_id'
balance = Blnk::Balance.create(ledger_id: 'ledger_id', currency: 'USD')

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/devton/blnk-ruby

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
