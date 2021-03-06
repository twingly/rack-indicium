# Rack::Indicium

[![Build Status](https://travis-ci.org/twingly/rack-indicium.svg)](https://travis-ci.org/twingly/rack-indicium)

If a [JSON Web Token (JWT)](http://jwt.io/) is sent in the header, it will be decoded and available in the `jwt.payload` and `jwt.header` rack `env` variables.

Optional integration with [Sentry Raven] for jwt-context to exceptions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-indicium'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-indicium

## Usage

```Ruby
require "rack/indicium"
require "rack/indicium/sentry" # Optional to add jwt context to Sentry
use Rack::Indicium, ENV.fetch("JWT_SECRET")
use Rack::Indicium::Sentry # Add after use Raven::Rack
run App
```

Once the middleware is included you get access to `jwt.header` and `jwt.payload` in the `env` object.

```Ruby
# It will only be set if there's a valid JWT that is verified with the jwt secret
payload = env.fetch("jwt.payload") { nil }
```

This could then be used for authorization

```Ruby
# Only allow requests from our clients
def authorized?
  payload = env.fetch("jwt.payload") { {} }
  payload["aud"] == ENV.fetch("CLIENT_ID")
end
```

If you need custom options to decode JWT, override the decoder:

```Ruby
require "rack/indicium"

unsafe_decoder = lambda { |jwt, secret| JWT.decode(jwt, secret, true, verify_expiration: false) }

use Rack::Indicium, ENV.fetch("JWT_SECRET"), unsafe_decoder
run App
```

## Contributing

1. Fork it ( https://github.com/twingly/rack-indicium/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[Sentry Raven]: https://github.com/getsentry/raven-ruby

## Release workflow

Build the gem.

    gem build rack-indicium.gemspec

[Publish](http://guides.rubygems.org/publishing/) the gem.

    gem push rack-indicium-x.y.z.gem
