# frozen_string_literal: true

require 'test_helper'

def stub_find_transaction_request_with_error
  stub_request(:get, %r{/transactions/(.*)})
    .to_return_json(body: { error: 'balance with ID \'transaction_id\' not found' }, status: 400)
end

def transaction_response_body # rubocop:disable Metrics/MethodLength
  {
    precise_amount: 7500,
    amount: 75,
    rate: 0,
    precision: 100,
    transaction_id: 'txn_bb8e13c5-1d16-4e94-add7-efd377fd551a',
    parent_transaction: '',
    source: 'bln_216507cb-2fb1-4238-a184-805c455f8fe2',
    destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
    reference: 'ref_005',
    currency: 'BRLX',
    description: 'For fees',
    status: 'QUEUED',
    hash: '74a2fecf01e73a31c005ce3bd840d285edce87e3bdb3e0ed99e0af124a6165f8',
    allow_overdraft: true,
    inflight: false,
    created_at: '2024-06-27T20:23:17.737289826Z',
    scheduled_for: '0001-01-01T00:00:00Z',
    inflight_expiry_date: '0001-01-01T00:00:00Z'
  }
end

def stub_find_transaction_request_with_success
  stub_request(:get, %r{/transactions/(.*)})
    .to_return_json(body: transaction_response_body, status: 200)
end

def stub_create_transaction_request_with_success
  stub_request(:post, %r{/transactions})
    .to_return_json(body: transaction_response_body, status: 200)
end

def stub_create_transaction_request_with_error
  stub_request(:post, %r{/transactions})
    .to_return_json(body: { error: 'missing transaction_id' }, status: 400)
end

# NOTE: This route does not exists, at least for now
def stub_all_transaction_request_with_error
  stub_request(:get, %r{/transactions})
    .to_return_json(body: { error: 'internal_server_error' }, status: 500)
end

def stub_all_transaction_request_with_success
  stub_request(:get, %r{/transactions})
    .to_return_json(body: [transaction_response_body], status: 200)
end

class TestTransaction < Minitest::Test
  def test_that_transaction_not_found
    stub_find_transaction_request_with_error
    find = Blnk::Transaction.find 'transaction_id'

    assert find.status.bad_request?
  end

  def test_that_transaction_find_success
    stub_find_transaction_request_with_success
    find = Blnk::Transaction.find 'transaction_id'

    assert find.is_a?(Blnk::Transaction)
    assert find.transaction_id.eql?(transaction_response_body[:transaction_id])
  end

  # NOTE: /transactions route does not exist, at moment
  # def test_that_transaction_all_error
  #   stub_all_transaction_request_with_error

  #   all = Blnk::Transaction.all

  #   assert !all.status.success?
  # end

  # def test_that_transaction_all_success
  #   stub_all_transaction_request_with_success

  #   all = Blnk::Transaction.all

  #   assert all.is_a?(Array)
  #   assert all.first.is_a?(Blnk::Transaction)
  #   assert all.first.transaction_id.eql?(transaction_response_body[:transaction_id])
  # end

  def test_that_transaction_create_errosr
    stub_create_transaction_request_with_error

    create = Blnk::Transaction.create

    assert create.status.bad_request?
  end

  def test_that_transaction_create_success
    stub_create_transaction_request_with_success

    create = Blnk::Transaction.create(ledger_id: 'ledger_id', currency: 'USD')

    assert create.is_a?(Blnk::Transaction)
    assert create.transaction_id.eql?(transaction_response_body[:transaction_id])
    assert create.name.eql?(transaction_response_body[:name])
  end
end
