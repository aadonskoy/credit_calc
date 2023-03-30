#frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'active_model'

%w[models services].each do |dir|
  Dir[File.join(File.dirname(__FILE__), dir, '*.rb')]
    .sort
    .each { |file| require file }
end

class App < Sinatra::Application
  get '/' do
    @errors = []
    haml :index
  end

  post '/payments' do
    @credit = Credit.new(params)
    if @credit.valid?
      @credit.calculate
      haml :payments
    else
      status 400
      @errors = @credit.errors.full_messages
      haml :index
    end
  end
end
