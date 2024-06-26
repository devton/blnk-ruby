# frozen_string_literal: true

module Blnk
  # Ledger representation
  class Ledger < Resourceable
    def self.resource_name = :ledgers

    def persisted? = !ledger_id.nil?
    def body_data = { name:, meta_data: }
  end
end
