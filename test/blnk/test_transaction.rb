# frozen_string_literal: true

require 'test_helper'

def stub_find_transaction_request_with_error
  stub_request(:get, %r{/transactions/(.*)})
    .to_return_json(body: { error: 'balance with ID \'transaction_id\' not found' }, status: 400)
end

def refunded_txn_body # rubocop:disable Metrics/MethodLength
  {
    transaction_id: 'txn_043d4ac3-4caf-4149-9c0d-927ae637d83f',
    tag: 'Refund',
    reference: 'ref_70ffd90f-7bcf-43b8-90ba-70505c113b52',
    amount: 300,
    currency: 'NGN',
    payment_method: '',
    description: '',
    drcr: 'Debit',
    status: 'APPLIED',
    ledger_id: 'ldg_073f7ffe-9dfd-42ce-aa50-d1dca1788adc',
    balance_id: 'bln_0be360ca-86fe-457d-be43-daa3f966d8f0',
    credit_balance_before: 600,
    debit_balance_before: 0,
    credit_balance_after: 600,
    debit_balance_after: 300,
    balance_before: 600,
    balance_after: 300,
    created_at: '2024-02-20T05:40:52.630481718Z',
    scheduled_for: '0001-01-01T00:00:00Z',
    risk_tolerance_threshold: 0,
    risk_score: 0.03108,
    meta_data: {
      refunded_transaction_id: 'txn_5bbbe4d3-2d82-4da1-8191-aaa491d025de'
    },
    group_ids: nil
  }
end

def transaction_response_body(opts: {}) # rubocop:disable Metrics/MethodLength
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
  }.merge(opts)
end

def stub_refund_transaction_request_with_success
  stub_request(:post, %r{/refund-transaction/(.*)})
    .to_return_json(body: refunded_txn_body, status: 200)
end

def stub_refund_transaction_request_with_error
  stub_request(:post, %r{/refund-transaction/(.*)})
    .to_return_json(body: { error: 'failed_refund_transaction' }, status: 400)
end

def stub_inflight_status_change_transaction_request_with_error(body: { status: 'commit' })
  stub_request(:put, %r{/transactions/inflight/(.*)})
    .with(body:)
    .to_return_json(body: { error: 'failed' }, status: 400)
end

def stub_inflight_status_change_transaction_request_with_success(body: { status: 'commit' })
  stub_request(:put, %r{/transactions/inflight/(.*)})
    .with(body:)
    .to_return_json(body: transaction_response_body, status: 200)
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

class TestTransaction < Minitest::Test # rubocop:disable Metrics/ClassLength
  def test_that_transaction_not_found
    stub_find_transaction_request_with_error
    find = Blnk::Transaction.find 'transaction_id'

    assert find.failure?
  end

  def test_that_transaction_find_success
    stub_find_transaction_request_with_success
    find = Blnk::Transaction.find 'transaction_id'

    assert find.success?
    assert find.value!.is_a?(Blnk::Transaction)
    assert find.value!.transaction_id.eql?(transaction_response_body[:transaction_id])
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

    assert create.failure?
  end

  def test_that_transaction_create_success # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    stub_create_transaction_request_with_success

    create = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true
    )

    assert create.success?
    assert create.value!.is_a?(Blnk::Transaction)
    assert create.value!.transaction_id.eql?(transaction_response_body[:transaction_id])
    assert create.value!.name.eql?(transaction_response_body[:name])
  end

  def test_that_transaction_refund_error # rubocop:disable Metrics/MethodLength
    stub_find_transaction_request_with_success
    stub_create_transaction_request_with_success
    stub_refund_transaction_request_with_error

    txn = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true
    )

    refund_txn = txn.value!.refund

    assert refund_txn.failure?
  end

  def test_that_transaction_refund_success # rubocop:disable Metrics/MethodLength
    stub_find_transaction_request_with_success
    stub_create_transaction_request_with_success
    stub_refund_transaction_request_with_success

    txn = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true
    )

    refund_txn = txn.value!.refund

    assert refund_txn.success?
    assert txn.value!.transaction_id != refund_txn.value!.transaction_id
  end

  def test_that_transaction_void_error # rubocop:disable Metrics/MethodLength
    stub_find_transaction_request_with_success
    stub_create_transaction_request_with_success
    stub_inflight_status_change_transaction_request_with_error(body: { status: 'void' })

    txn = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true,
      inflight: true
    )

    void_txn = txn.value!.void

    assert void_txn.failure?
  end

  def test_that_transaction_void_success # rubocop:disable Metrics/MethodLength
    stub_find_transaction_request_with_success
    stub_create_transaction_request_with_success
    stub_inflight_status_change_transaction_request_with_success(body: { status: 'void' })

    txn = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true,
      inflight: true
    )

    void_txn = txn.value!.void

    assert void_txn.success?
  end

  def test_that_transaction_commit_error # rubocop:disable Metrics/MethodLength
    stub_find_transaction_request_with_success
    stub_create_transaction_request_with_success
    stub_inflight_status_change_transaction_request_with_error(body: { status: 'commit' })

    txn = Blnk::Transaction.create(
      amount: 75,
      reference: 'ref_005',
      currency: 'BRLX',
      precision: 100,
      source: '@world',
      destination: 'bln_469f93bc-40e9-4e0e-b6ab-d11c3638c15d',
      description: 'For fees',
      allow_overdraft: true,
      inflight: true
    )

    commit_txn = txn.value!.commit

    assert commit_txn.failure?
  end
end
