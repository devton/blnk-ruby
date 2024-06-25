# frozen_string_literal: true

module Blnk
  # HTTP Client to do the requests to blnk server
  module Client
    def client
      ::HTTP.headers(
        'X-Blnk-Key': Blnk.secret_token,
        'Content-Type': 'application/json',
        accept: 'application/json'
      )
    end

    def get_request(path:, params: nil)
      client.get(base_uri(path:), params:)
    end

    def put_request(path:, body:)
      client.put(base_uri(path:), json: body)
    end

    def post_request(path:, body:)
      client.post(base_uri(path:), json: body)
    end

    def base_uri(path:, uri: Blnk.address)
      uri = URI(uri)
      uri.path = path if path
      uri
    end
  end
end
