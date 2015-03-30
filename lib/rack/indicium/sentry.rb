require "rack/indicium/version"

module Rack
  class Indicium
    class Sentry
      def initialize(app)
        @app = app

        if defined?(Raven)
          @sentry_client = Raven
        end
      end

      def call(env)
        check_for_jwt(env)
        @app.call(env)
      end

      def check_for_jwt(env)
        return unless enabled?

        context = {
          "jwt.header" => env["jwt.header"],
          "jwt.payload" => env["jwt.payload"],
        }
        client.extra_context(context)
      end

      def client
        @sentry_client
      end

      def enabled?
        !!@sentry_client
      end
    end
  end
end
