# frozen_string_literal: true

require 'http'
require 'ostruct'
require_relative 'blnk/version'
require_relative 'blnk/client'
require_relative 'blnk/resourceable'
require_relative 'blnk/ledger'
require_relative 'blnk/balance'
require_relative 'blnk/transaction'

module Blnk
  class Error < StandardError; end

  class << self
    attr_accessor :address, :secret_token, :search_api_key
  end

  self.address = ENV.fetch('BLNK_ADDRESS', nil)
  self.secret_token = ENV.fetch('BLNK_SECRET_TOKEN', nil)
  self.search_api_key = ENV.fetch('BLNK_SEARCH_API_KEY', nil)
end
