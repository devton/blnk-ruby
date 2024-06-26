# frozen_string_literal: true

module Blnk
  # Balance representation
  class Balance < Resourceable
    def self.resource_name = :balances

    def persisted? = !balance_id.nil?
    def body_data = { ledger_id:, currency: }
  end
end
