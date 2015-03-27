require "rack/indicium/version"
require "jwt"

module Rack
  class Indicium

    HTTP_AUTHORIZATION = "HTTP_AUTHORIZATION".freeze
    BEARER_REGEXP = /\ABearer /i

    def initialize(app, secret, decoder = nil)
      @app = app

      @secret = secret
      @decoder = decoder || lambda { |jwt, secret| JWT.decode(jwt, secret) }
    end

    def call(env)
      look_for_authorization_header(env)

      @app.call(env)
    end

    def look_for_authorization_header(env)
      authorization_header = env[HTTP_AUTHORIZATION]
      return unless authorization_header

      _, jwt = authorization_header.split(BEARER_REGEXP)
      return unless jwt

      jwt_payload, jwt_header = decode(jwt)

      return unless jwt_payload
      return unless jwt_header

      env["jwt.payload"] = jwt_payload
      env["jwt.header"]  = jwt_header
    end

    def decode(jwt)
      @decoder.call(jwt, @secret)
    rescue
    end
  end
end
