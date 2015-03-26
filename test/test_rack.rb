require 'minitest_helper'

class TestRack < Minitest::Test
  def setup
    @application = lambda { |env| [200, { "Content-Type" => "text/plain" }, "OK"] }
    @secret = "s3cr3t"
  end

  def test_that_middleware_works_with_application
    middleware = Rack::Indicium.new(@application, @secret)
    env = Rack::MockRequest.env_for('/api')

    code, header, body = middleware.call(env)

    assert_equal "OK", body
  end

  def test_jwt_header
    middleware = Rack::Indicium.new(@application, @secret)
    jwt_payload = { "exp" => Time.now.to_i + 10, "custom" => 1337 }
    jwt_header  = { "typ" => "JWT", "alg" => "HS256" }
    jwt = JWT.encode(jwt_payload, @secret, jwt_header["alg"])
    env = Rack::MockRequest.env_for('/api', { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" })

    middleware.call(env)

    assert_equal jwt_payload, env["jwt.payload"]
    assert_equal jwt_header, env["jwt.header"]
  end

  def test_with_broken_jwt
    middleware = Rack::Indicium.new(@application, @secret)
    env = Rack::MockRequest.env_for('/api', { "HTTP_AUTHORIZATION" => "Bearer broken" })

    code, header, body = middleware.call(env)

    refute env.keys.include?("jwt.payload"), "jwt.payload should not exist"
    refute env.keys.include?("jwt.header"), "jwt.header should not exist"
    assert_equal "OK", body
  end

  def test_with_expired_token
    middleware = Rack::Indicium.new(@application, @secret)
    jwt_payload = { "exp" => Time.now.to_i - 10 }
    jwt_header  = { "typ" => "JWT", "alg" => "HS256" }
    jwt = JWT.encode(jwt_payload, @secret, jwt_header["alg"])
    env = Rack::MockRequest.env_for('/api', { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" })

    code, header, body = middleware.call(env)

    refute env.keys.include?("jwt.payload"), "jwt.payload should not exist"
    refute env.keys.include?("jwt.header"), "jwt.header should not exist"
    assert_equal "OK", body
  end

  def test_jwt_header_with_expired_token_when_its_ok
    decoder = lambda { |jwt, secret| JWT.decode(jwt, secret, true, verify_expiration: false) }
    middleware = Rack::Indicium.new(@application, @secret, decoder)

    jwt_payload = { "exp" => Time.now.to_i - 10, "custom" => 1337 }
    jwt_header  = { "typ" => "JWT", "alg" => "HS256" }
    jwt = JWT.encode(jwt_payload, @secret, jwt_header["alg"])
    env = Rack::MockRequest.env_for('/api', { "HTTP_AUTHORIZATION" => "Bearer #{jwt}" })

    code, header, body = middleware.call(env)

    assert_equal jwt_payload, env["jwt.payload"]
    assert_equal jwt_header, env["jwt.header"]
  end
end
