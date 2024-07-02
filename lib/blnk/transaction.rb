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

    def refund = short_hander(resp: req_refund)
    def void = short_hander(resp: req_inflight(body: { status: 'void' }))
    def commit = short_hander(resp: req_inflight(body: { status: 'commit' }))

    private

    def short_hander(resp:) = with_handler(resp:, kself: self)
    def inflight_path = "/transactions/inflight/#{_id}"
    def refund_path = "/refund-transaction/#{_id}"
    def req_inflight(body:) = put_request(path: inflight_path, body:)
    def req_refund = post_request(path: refund_path, body: nil)
  end
end
