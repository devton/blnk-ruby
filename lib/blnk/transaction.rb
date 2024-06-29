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
        optional(:scheduled_for).value(:string)
      end
    end

    self.resource_name = :transactions
    self.id_field = :transaction_id
    self.create_contract = CreateContract

    def refund = self.class.with_req(req: request_refund, self_caller: self)
    def void = raise NotImplementedError
    def commit = raise NotImplementedError

    private

    def inflight_path = "/transactions/inflight/#{_id}"
    def refund_path = "/refund-transactions/#{_id}"
    def request_update_inflight(body:, path: inflight_path) = self.class.put_request(path:, body:)
    def request_refund(path: refund_path) = self.class.post_request(path:, body: nil)
  end
end
