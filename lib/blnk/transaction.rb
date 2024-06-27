# frozen_string_literal: true

module Blnk
  # Transaction representation
  class Transaction < Resourceable
    def self.resource_name = :transactions
    def self.id_field = :transaction_id

    def body_data = {}
  end
end
