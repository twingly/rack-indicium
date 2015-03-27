require "spec_helper"
require "rack/test"
require "grape"
require "json"

JWT_SECRET = "s3cr3t"

class GrapeApi < Grape::API
  use Rack::Indicium, JWT_SECRET

  format :json

  resource :test do
    desc "Return jwt payload"
    get do
      env.fetch("jwt.payload") { {} }
    end
  end
end

describe GrapeApi do
  include Rack::Test::Methods

  def app
    GrapeApi
  end

  describe "GET /test" do
    let(:secret) { JWT_SECRET }
    let(:jwt_extra_content) do
      { "user_uuid" => "E3F6D525-68E8-490F-A3C9-EAD340C4F907" }
    end

    before do
      authorization_request_header(secret, jwt_extra_content)
      get "/test"
    end

    subject { JSON.parse(last_response.body) }

    context "with a valid JWT secret" do
      it { is_expected.to include(jwt_extra_content) }
    end

    context "with an invalid JWT secret" do
      let(:secret) { "invalid" }
      it { is_expected.to_not include(jwt_extra_content) }
    end
  end
end
