# frozen_string_literal: true

module Blnk
  # Transaction representation
  class Transaction < Resourceable
    class CreateContract < Dry::Validation::Contract
      schema do
        required(:amount).value(:integer)
        required(:precision).value(:integer)
        required(:currency).value(:string)
        required(:reference).value(:string)
        required(:source).value(:string)
        required(:destination).value(:string)
        required(:description).value(:string)
        required(:allow_overdraft).value(:bool)
        optional(:inflight).value(:bool)
        optional(:rate).value(:integer)
      end
    end

    self.resource_name = :transactions
    self.id_field = :transaction_id
    self.create_contract = CreateContract
  end
end
