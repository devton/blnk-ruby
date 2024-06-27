# frozen_string_literal: true

module Blnk
  # Resoureable module that bring some tweaks for basic REST api integration
  class Resourceable < OpenStruct
    class SearchResult < OpenStruct; end

    include Client

    class << self
      def resource_name = raise NotImplementedError
      def id_field = :id

      def find(id)
        response = new.get_request(path: "/#{resource_name}/#{id}")
        return response unless response.status.success?

        new response.parse
      end

      def all
        response = new.get_request(path: "/#{resource_name}")
        return response unless response.status.success?

        response.parse.map do |r|
          new r
        end
      end

      def create(**args)
        response = new.post_request(
          path: "/#{resource_name}",
          body: args
        )
        return response unless response.status.success?

        new(response.parse)
      end

      def search(**args)
        response = new.post_request(
          path: "/search/#{resource_name}",
          body: args
        )
        return response unless response.status.success?

        sr = SearchResult.new(response.parse)
        sr.resource_name = resource_name
        sr
      end
    end

    def persisted? = table[self.class.id_field]
    def body_data = raise NotImplementedError
  end
end
