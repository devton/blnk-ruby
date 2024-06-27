# frozen_string_literal: true

module Blnk
  # Transaction representation
  class Transaction < Resourceable
    def self.resource_name = :transactions

    def persisted? = !transaction_id.nil?
    def body_data = {}
  end
end
