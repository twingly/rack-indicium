module Helpers
  def jwt_header
    { "typ" => "JWT", "alg" => "HS256" }
  end

  def expired_jwt_payload
    { "exp" => Time.now.to_i - 10, "custom" => 1337 }
  end

  def valid_jwt_payload
    { "exp" => Time.now.to_i + 10, "custom" => 1337 }
  end

  def valid_jwt(secret)
    encode_jwt(valid_jwt_payload, secret)
  end

  def encode_jwt(contents, secret)
    JWT.encode(contents, secret)
  end

  def authorization_request_header(secret, extra_contents = {})
    contents = {
      "aud" => "some_id",
      "sub" => "user_id",
    }.merge(extra_contents)

    jwt = encode_jwt(contents, secret)

    header "Authorization", "Bearer #{jwt}"
  end
end
