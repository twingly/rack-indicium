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
end
