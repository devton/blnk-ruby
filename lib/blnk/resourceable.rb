# frozen_string_literal: true

module Blnk
  # Resoureable module that bring some tweaks for basic REST api integration
  class Resourceable < OpenStruct
    class SearchResult < OpenStruct; end

    include Client

    def self.resource_name = raise NotImplementedError

    def self.find(id)
      response = new.get_request(path: "/#{resource_name}/#{id}")
      return response unless response.status.success?

      new response.parse
    end

    def self.all
      response = new.get_request(path: "/#{resource_name}")
      return response unless response.status.success?

      response.parse.map do |r|
        new r
      end
    end

    def self.create(*)
      response = new.post_request(
        path: "/#{resource_name}",
        body: new(*).body_data
      )
      return response unless response.status.success?

      new(response.parse)
    end

    def self.search(**args)
      response = new.post_request(
        path: "/search/#{resource_name}",
        body: args
      )
      return response unless response.status.success?

      sr = SearchResult.new(response.parse)
      sr.resource_name = resource_name
      sr
    end

    def persisted? = raise NotImplementedError
    def body_data = raise NotImplementedError
  end
end
