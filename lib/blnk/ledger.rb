# frozen_string_literal: true

module Blnk
  # Ledger representation
  class Ledger < OpenStruct
    include Client

    def self.find(id)
      response = new.get_request(path: "/ledgers/#{id}")
      return response.parse unless response.status.success?

      new response.parse
    end

    def self.all
      response = new.get_request(path: '/ledgers')
      return response.parse unless response.status.success?

      response.parse.map do |r|
        new r
      end
    end

    def save
      response = post_request(path: '/ledgers', body: body_data)
      return response.parse unless response.status.success?

      # self.class.new response.parse

      response.parse.each_pair { |k, v| self[k] = v }
      self
    end

    private

    def body_data
      {
        name:,
        meta_data:
      }
    end
  end
end
