# frozen_string_literal: true

module Blnk
  # Resoureable module that bring some tweaks for basic REST api integration
  class Resourceable < OpenStruct
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

    def self.create(**create_args)
      new(**create_args).save
    end

    def save
      return self if persisted?

      response = post_request(path: "/#{self.class.resource_name}", body: body_data)
      return response unless response.status.success?

      response.parse.each_pair { |k, v| self[k] = v }
      self
    end

    def create_args = {}
    def persisted? = raise NotImplementedError
    def body_data = raise NotImplementedError
  end
end
