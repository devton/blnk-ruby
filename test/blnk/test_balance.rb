# frozen_string_literal: true

require 'test_helper'

def stub_find_balance_request_with_error
  stub_request(:get, %r{/balances/(.*)})
    .to_return_json(body: { error: 'balance with ID \'BALANCE_ID\' not found' }, status: 400)
end

def balance_response_body
  { balance: 0,
    version: 1,
    inflight_balance: 0,
    credit_balance: 0,
    inflight_credit_balance: 0,
    debit_balance: 0,
    inflight_debit_balance: 0,
    precision: 0,
    ledger_id: 'ldg_6ef6ed08-a878-47a5-85d8-416c4db94920',
    identity_id: '',
    balance_id: 'bln_70eb9468-4b5c-4d7a-bc37-f9d18088ef15',
    indicator: '',
    currency: 'USD',
    created_at: '2024-06-26T01:19:35.122774Z',
    inflight_expires_at: '0001-01-01T00:00:00Z',
    meta_data: nil }
end

def stub_find_balance_request_with_success
  stub_request(:get, %r{/balances/(.*)})
    .to_return_json(body: balance_response_body, status: 200)
end

def stub_create_balance_request_with_success
  stub_request(:post, %r{/balances})
    .to_return_json(body: balance_response_body, status: 200)
end

def stub_create_balance_request_with_error
  stub_request(:post, %r{/balances})
    .to_return_json(body: { error: 'missing balance_id' }, status: 400)
end

# NOTE: This route does not exists, at least for now
def stub_all_balance_request_with_error
  stub_request(:get, %r{/balances})
    .to_return_json(body: { error: 'internal_server_error' }, status: 500)
end

def stub_all_balance_request_with_success
  stub_request(:get, %r{/balances})
    .to_return_json(body: [balance_response_body], status: 200)
end

class TestLedger < Minitest::Test
  def test_that_balance_not_found
    stub_find_balance_request_with_error
    find = Blnk::Balance.find 'BALANCE_ID'

    assert find.status.bad_request?
  end

  def test_that_balance_find_success
    stub_find_balance_request_with_success
    find = Blnk::Balance.find 'BALANCE_ID'

    assert find.is_a?(Blnk::Balance)
    assert find.balance_id.eql?(balance_response_body[:balance_id])
  end

  # NOTE: /balances route does not exist, at moment
  # def test_that_balance_all_error
  #   stub_all_balance_request_with_error

  #   all = Blnk::Balance.all

  #   assert !all.status.success?
  # end

  # def test_that_balance_all_success
  #   stub_all_balance_request_with_success

  #   all = Blnk::Balance.all

  #   assert all.is_a?(Array)
  #   assert all.first.is_a?(Blnk::Balance)
  #   assert all.first.balance_id.eql?(balance_response_body[:balance_id])
  # end

  def test_that_balance_create_errosr
    stub_create_balance_request_with_error

    create = Blnk::Balance.create

    assert create.status.bad_request?
  end

  def test_that_balance_create_success
    stub_create_balance_request_with_success

    create = Blnk::Balance.create(ledger_id: 'ledger_id', currency: 'USD')

    assert create.is_a?(Blnk::Balance)
    assert create.balance_id.eql?(balance_response_body[:balance_id])
    assert create.name.eql?(balance_response_body[:name])
  end
end
