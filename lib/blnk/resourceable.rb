# frozen_string_literal: true

module Blnk
  # Resoureable module that bring some tweaks for basic REST api integration
  class Resourceable < OpenStruct
    extend Client
    extend Forwardable

    def_delegators :'self.class', :put_request, :post_request, :get_request, :with_handler

    class SearchResult < OpenStruct; end

    class DefaultSearchContract < Dry::Validation::Contract
      schema do
        required(:q).value(:string)
      end
    end

    class << self
      include Dry::Monads[:result]

      attr_accessor :resource_name, :id_field, :create_contract, :search_contract

      def resources_path = "/#{resource_name}"
      def resource_path(id) = "/#{resource_name}/#{id}"
      def search_path = "/search/#{resource_name}"

      def find(id) = with_handler resp: find_request(id)
      def find_request(id) = get_request(path: resource_path(id))

      def all
        check_vars
        resp = get_request(path: resources_path)
        with_handler(resp:, block: method(:all_handler))
      end

      def create(**args)
        wrap_call(create_contract_new, args) do |contract|
          with_handler(resp: post_request(path: resources_path, body: contract.to_h))
        end
      end

      def search(**args)
        wrap_call(search_contract_new, args) do |contract|
          with_handler(resp: post_request(path: search_path, body: contract.to_h),
                       block: method(:search_handler))
        end
      end

      def check_vars
        raise NotImplementedError, 'missing self.resource_name' unless resource_name
        raise NotImplementedError, 'missing self.id_field' unless id_field
        raise NotImplementedError, 'missing self.create_contract' unless create_contract
      end

      def wrap_call(contract, args)
        check_vars
        ccall = contract.call(args)
        return Failure(ccall.errors.to_h) if ccall.failure?

        return yield ccall if block_given?

        ccall
      end

      def create_contract_new
        return create_contract.new if create_contract

        raise NotImplementedError, 'missing self.create_contract'
      end

      def search_contract_new = (search_contract || DefaultSearchContract).new

      def search_handler(parsed, status)
        success = status.success?
        result = SearchResult.new(parsed) if success

        inj_handler(result:, success:, error: parsed)
      end

      def all_handler(parsed, status)
        success = status.success?
        result = parsed.map { |r| new(r) } if success
        inj_handler(success:, result:, error: parsed)
      end

      def handler(parsed, status)
        inj_handler(
          result: new(parsed),
          error: parsed,
          success: status.success?
        )
      end

      def inj_handler(result:, error:, success:)
        (success ? Success(result) : Failure(error))
      end

      def with_handler(resp:, kself: nil, block: method(:handler))
        using_resp(resp:, kself:, &block)
      end

      def using_resp(resp:, kself: nil, &block)
        check_vars
        parsed = resp.parse
        parsed = parsed.transform_keys(&:to_sym) unless parsed.is_a?(Array)

        kself&.reload

        block.call(parsed, resp.status)
      end
    end

    def reload
      self.class.find_request(_id).tap do |res|
        next unless res.status.success?

        res.parse.each_pair do |k, v|
          self[k] = v
        end
      end
      self
    end

    # table[self.class.id_field]
    def persisted? = !_id.nil?
    def _id = public_send(self.class.id_field)
  end
end
