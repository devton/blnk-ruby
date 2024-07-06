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
        optional(:source).value(:string)
        optional(:sources).array(:hash) do
          required(:identifier).value(:string)
          required(:distribution).value(:string)
          required(:narration).value(:string)
        end
        optional(:destination).value(:string)
        optional(:destinations).array(:hash) do
          required(:identifier).value(:string)
          required(:distribution).value(:string)
          required(:narration).value(:string)
        end
        required(:description).value(:string)
        required(:allow_overdraft).value(:bool)
        optional(:inflight).value(:bool)
        optional(:rate).value(:integer)
        optional(:scheduled_for).value(:string)
      end

      rule do
        base.failure('must only contain one of source, sources') if key?(:source) && key?(:sources)

        if key?(:destination) && key?(:destinations)
          base.failure('must only contain one of destination, destinations')
        end

        if values[:source].to_s.empty? && values[:sources].to_s.empty?
          key(:source).failure('missing source')
        end

        if values[:destination].to_s.empty? && values[:destinations].to_s.empty?
          key(:destination).failure('missing destination')
        end
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
