# frozen_string_literal: true

module Blnk
  # Ledger representation
  class Ledger < Resourceable
    class CreateContract < Dry::Validation::Contract
      schema do
        required(:name).value(:string)
        optional(:meta_data).value(:hash)
      end
    end

    self.resource_name = :ledgers
    self.id_field = :ledger_id
    self.create_contract = CreateContract
  end
end
