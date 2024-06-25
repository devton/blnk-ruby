# frozen_string_literal: true

require 'test_helper'

def stub_find_ledger_request_with_error
  stub_request(:get, %r{/ledgers/(.*)})
    .to_return_json(body: { error: 'ledger with ID \'LEDGER_ID\' not found' }, status: 400)
end

def ledger_response_body
  {
    ledger_id: 'ldg_f2db7af4-a445-41e3-b233-c052e4283a6b',
    name: 'ledger_name',
    created_at: '2024-06-15T08:55:03.943273Z',
    meta_data: {
      'account_id' => '9a521e1d-6f76-4260-b35f-6180a64e0331',
      'org_adm' => 'Lorem Ipsum dolor',
      'org_slug' => 'lorem-ipsum'
    }
  }
end

def stub_find_ledger_request_with_success
  stub_request(:get, %r{/ledgers/(.*)})
    .to_return_json(body: ledger_response_body, status: 200)
end

def stub_create_ledger_request_with_success
  stub_request(:post, %r{/ledgers})
    .to_return_json(body: ledger_response_body, status: 200)
end

def stub_create_ledger_request_with_error
  stub_request(:post, %r{/ledgers})
    .to_return_json(body: { error: 'missing name' }, status: 400)
end

def stub_all_ledger_request_with_error
  stub_request(:get, %r{/ledgers})
    .to_return_json(body: { error: 'internal_server_error' }, status: 500)
end

def stub_all_ledger_request_with_success
  stub_request(:get, %r{/ledgers})
    .to_return_json(body: [ledger_response_body], status: 200)
end

class TestLedger < Minitest::Test
  def test_that_ledger_not_found
    stub_find_ledger_request_with_error
    find = Blnk::Ledger.find 'LEDGER_ID'

    assert find.status.bad_request?
  end

  def test_that_ledger_find_success
    stub_find_ledger_request_with_success
    find = Blnk::Ledger.find 'LEDGER_ID'

    assert find.is_a?(Blnk::Ledger)
    assert find.ledger_id.eql?(ledger_response_body[:ledger_id])
  end

  def test_that_ledger_all_error
    stub_all_ledger_request_with_error

    all = Blnk::Ledger.all

    assert !all.status.success?
  end

  def test_that_ledger_all_success
    stub_all_ledger_request_with_success

    all = Blnk::Ledger.all

    assert all.is_a?(Array)
    assert all.first.is_a?(Blnk::Ledger)
    assert all.first.ledger_id.eql?(ledger_response_body[:ledger_id])
  end

  def test_that_ledger_create_errosr
    stub_create_ledger_request_with_error

    create = Blnk::Ledger.create

    assert create.status.bad_request?

    create_with_new = Blnk::Ledger.new.save

    assert create_with_new.status.bad_request?
  end

  def test_that_ledger_create_success
    stub_create_ledger_request_with_success

    create = Blnk::Ledger.create(name: 'ledger_name')

    assert create.is_a?(Blnk::Ledger)
    assert create.ledger_id.eql?(ledger_response_body[:ledger_id])
    assert create.name.eql?(ledger_response_body[:name])
  end

  def test_that_ledger_create_success_using_new
    stub_create_ledger_request_with_success

    create_with_new = Blnk::Ledger.new name: 'ledger_name'
    create_with_new.save

    assert create_with_new.is_a?(Blnk::Ledger)
    assert create_with_new.ledger_id.eql?(ledger_response_body[:ledger_id])
    assert create_with_new.name.eql?(ledger_response_body[:name])
  end
end
