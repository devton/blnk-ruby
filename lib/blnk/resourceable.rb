# frozen_string_literal: true

module Blnk
  # Resoureable module that bring some tweaks for basic REST api integration
  class Resourceable < OpenStruct
    extend Client

    class SearchResult < OpenStruct; end

    class DefaultSearchContract < Dry::Validation::Contract
      schema do
        required(:q).value(:string)
      end
    end

    class << self
      include Dry::Monads[:result]

      attr_accessor :resource_name, :id_field, :create_contract, :search_contract

      def find(id) = with_req resp: get_request(path: "/#{resource_name}/#{id}")

      def all
        check_vars
        res = get_request(path: "/#{resource_name}")
        return Failure(res.parse&.transform_keys(&:to_sym)) unless res.status.success?

        Success(res.parse.map { |r| new(r) })
      end

      def create(**args)
        contract = wrap_call(create_contract_new, args)
        return contract if contract.failure?

        res = post_request(path: "/#{resource_name}", body: contract.to_h)
        return Failure(res.parse&.transform_keys(&:to_sym)) unless res.status.success?

        Success(new(res.parse))
      end

      def search(**args)
        contract = wrap_call(search_contract_new, args)
        return contract if contract.failure?

        res = post_request(path: "/search/#{resource_name}", body: contract.to_h)
        return Failure(res.parse&.transform_keys(&:to_sym)) unless res.status.success?

        result = SearchResult.new(res.parse.merge(resource_name:))
        Success(result)
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

        ccall
      end

      def create_contract_new
        return create_contract.new if create_contract

        raise NotImplementedError, 'missing self.create_contract'
      end

      def search_contract_new = (search_contract || DefaultSearchContract).new

      def handler(parsed, status) = (status.success? ? Success(new(parsed)) : Failure(parsed))
      def with_req(resp:, self_caller: nil) = using_resp(resp:, self_caller:, &method(:handler))

      def using_resp(resp:, self_caller: nil, &block)
        check_vars
        parsed = resp.parse.transform_keys(&:to_sym)
        self_caller&.reload

        block.call(parsed, resp.status)
      end
    end

    def reload
      self.class.find(_id) do |res|
        next unless res.status.success?

        res.parse.each_pair do |k, v|
          self[k] = v
        end
        self
      end
    end

    # table[self.class.id_field]
    def persisted? = !_id.nil?
    def _id = public_send(self.class.id_field)
  end
end
