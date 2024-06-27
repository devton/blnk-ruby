# frozen_string_literal: true

module Blnk
  # Ledger representation
  class Ledger < Resourceable
    def self.resource_name = :ledgers
    def self.id_field = :ledger_id

    def body_data = { name:, meta_data: }
  end
end
