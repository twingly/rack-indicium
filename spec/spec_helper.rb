require 'rack/mock'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/indicium'

require_relative 'helpers'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Helpers
end
