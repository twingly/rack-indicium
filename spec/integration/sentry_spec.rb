require "spec_helper"

describe Rack::Indicium::Sentry, "env" do

  let(:application) { lambda { |env| [200, { "Content-Type" => "text/plain" }, "OK"] } }
  let(:middleware)  { Rack::Indicium::Sentry.new(application) }
  let(:header)      { {} }
  let(:env)         { Rack::MockRequest.env_for('/api', header) }
  let(:jwt_context) { { "jwt.header" => jwt_header, "jwt.payload" => valid_jwt_payload } }

  subject do
    object_double("Raven", extra_context: true).as_stubbed_const
  end

  context "when Raven is defined" do
    before do
      subject # To define Raven (double)
    end

    it "the middleware should be set" do
      expect(middleware.enabled?).to eq(true)
    end

    context "with jwt.header and jwt.payload" do
      before do
        jwt_context.each do |key, value|
          env[key] = value
        end
        middleware.call(env)
      end

      context "with jwt.header is set" do
        it { is_expected.to have_received(:extra_context).with(jwt_context) }
      end

      context "with jwt.payload is set" do
        it { is_expected.to have_received(:extra_context).with(jwt_context) }
      end
    end
  end

  context "When Raven is not defined" do
    it "the middleware should be set" do
      expect(middleware.enabled?).to eq(false)
    end
  end

  context "when middleware is not enabled" do
    before do
      allow(middleware).to receive(:enabled?) { false }
      jwt_context.each do |key, value|
        env[key] = value
      end
      middleware.call(env)
    end

    context "with jwt.header set" do
      it { is_expected.to_not have_received(:extra_context) }
    end

    context "without jwt.payload set" do
      it { is_expected.to_not have_received(:extra_context) }
    end
  end
end
