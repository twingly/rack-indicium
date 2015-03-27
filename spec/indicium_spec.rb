require "spec_helper"

describe Rack::Indicium, "env" do

  let(:application) { lambda { |env| [200, { "Content-Type" => "text/plain" }, "OK"] } }
  let(:middleware)  { Rack::Indicium.new(application, secret) }
  let(:secret)      { "s3cr3t" }
  let(:header)      { {} }
  let(:env)         { Rack::MockRequest.env_for('/api', header) }

  def get_response
    middleware.call(env)
  end

  subject(:response_code)   { get_response[0] }
  subject(:response_header) { get_response[1] }
  subject(:response_body)   { get_response[2] }
  subject { env }

  before { get_response }

  context "without jwt" do
    it "should just pass through a request" do
      expect(response_code).to eq(200)
      expect(response_body).to eq("OK")
    end
  end

  context "with a valid jwt header" do
    let(:jwt)         { JWT.encode(valid_jwt_payload, secret, jwt_header["alg"]) }
    let(:header)      { { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" } }

    it { is_expected.to include({ "jwt.header" => jwt_header }) }
    it { is_expected.to include({ "jwt.payload" => valid_jwt_payload }) }
  end

  context "with a broken jwt" do
    let(:header) { { "HTTP_AUTHORIZATION" => "Bearer broken" } }

    it "should just pass through a request" do
      expect(response_code).to eq(200)
      expect(response_body).to eq("OK")
    end

    it { is_expected.to_not include("jwt.header") }
    it { is_expected.to_not include("jwt.payload") }
  end

  context "with an expired jwt" do
    let(:jwt)         { JWT.encode(expired_jwt_payload, secret, jwt_header["alg"]) }
    let(:header)      { { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" } }

    context "with default decoder" do
      it "should not decode jwt" do
        expect(response_code).to eq(200)
        expect(response_body).to eq("OK")
      end

      it { is_expected.to_not include("jwt.header") }
      it { is_expected.to_not include("jwt.payload") }
    end

    context "with a custom decoder " do
      let(:decoder)    { lambda { |jwt, secret| JWT.decode(jwt, secret, true, verify_expiration: false) } }
      let(:middleware) { Rack::Indicium.new(application, secret, decoder) }

      it { is_expected.to include({ "jwt.header" => jwt_header }) }
      it { is_expected.to include({ "jwt.payload" => expired_jwt_payload }) }
    end
  end
end
