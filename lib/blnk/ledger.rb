# frozen_string_literal: true

module Blnk
  # Ledger representation
  class Ledger
    include Client

    def initialize(name:, metadata:)
      @name = name
      @metadata = metadata
    end
  end
end
