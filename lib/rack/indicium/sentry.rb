require "rack/indicium/version"

module Rack
  class Indicium
    class Sentry
      def initialize(app)
        @app = app

        if defined?(Raven)
          @sentry_client = Raven
        else
          warn "%s: Raven not definied, can't send JWT headers to Sentry." % self.class.to_s
        end
      end

      def call(env)
        check_for_jwt(env) if enabled?
        @app.call(env)
      end

      def check_for_jwt(env)
        context = {
          "jwt.raw" => env["jwt.raw"],
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
