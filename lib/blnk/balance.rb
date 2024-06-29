# frozen_string_literal: true

module Blnk
  # Balance representation
  class Balance < Resourceable
    class CreateContract < Dry::Validation::Contract
      schema do
        required(:ledger_id).value(:string)
        required(:currency).value(:string)
      end
    end

    self.resource_name = :balances
    self.id_field = :balance_id
    self.create_contract = CreateContract
  end
end
