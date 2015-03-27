require "spec_helper"

describe Rack::Indicium do

  let(:application) { lambda { |env| [200, { "Content-Type" => "text/plain" }, "OK"] } }
  let(:middleware)  { Rack::Indicium.new(application, secret) }
  let(:secret)      { "s3cr3t" }

  context "without jwt" do
    let(:env) { Rack::MockRequest.env_for('/api') }

    it "should just pass through a request" do
      code, header, body = middleware.call(env)
      expect(code).to eq(200)
      expect(body).to eq("OK")
    end
  end

  context "with a valid jwt header" do
    let(:jwt_payload) { { "exp" => Time.now.to_i + 10, "custom" => 1337 } }
    let(:jwt_header)  { { "typ" => "JWT", "alg" => "HS256" } }
    let(:jwt) { JWT.encode(jwt_payload, secret, jwt_header["alg"]) }
    let(:header) { { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" } }

    let(:env) { Rack::MockRequest.env_for('/api', header) }

    it "should decode jwt" do
      code, header, body = middleware.call(env)

      expect(env["jwt.header"]).to include(jwt_header)
      expect(env["jwt.payload"]).to include(jwt_payload)
    end
  end

  context "with a broken jwt" do
    let(:header) { { "HTTP_AUTHORIZATION" => "Bearer broken" } }
    let(:env) { Rack::MockRequest.env_for('/api', header) }

    it "should just pass through a request" do
      code, header, body = middleware.call(env)

      expect(code).to eq(200)
      expect(body).to eq("OK")
      expect(env).to_not include("jwt.header")
      expect(env).to_not include("jwt.payload")
    end
  end

  context "with an expired jwt" do
    let(:jwt_payload) { { "exp" => Time.now.to_i - 10, "custom" => 1337 } }
    let(:jwt_header)  { { "typ" => "JWT", "alg" => "HS256" } }
    let(:jwt) { JWT.encode(jwt_payload, secret, jwt_header["alg"]) }
    let(:header) { { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" } }
    let(:env) { Rack::MockRequest.env_for('/api', header) }

    context "with default decoder" do
      it "should not decode jwt" do
        code, header, body = middleware.call(env)

        expect(code).to eq(200)
        expect(body).to eq("OK")
        expect(env).to_not include("jwt.header")
        expect(env).to_not include("jwt.payload")
      end
    end

    context "with a custom decoder " do
      let(:decoder) { lambda { |jwt, secret| JWT.decode(jwt, secret, true, verify_expiration: false) } }
      let(:middleware) { Rack::Indicium.new(application, secret, decoder) }
      it "should decode jwt" do
        code, header, body = middleware.call(env)

        expect(env["jwt.header"]).to include(jwt_header)
        expect(env["jwt.payload"]).to include(jwt_payload)
      end
    end
  end
end
