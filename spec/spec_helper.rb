require 'rack/test'
require 'rspec'
require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods

end
