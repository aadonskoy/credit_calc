require 'bundler/setup'
require 'sinatra'
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }
# require_relative 'models/credit.rb'

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
      @errors = @credit.error_messages
      haml :index
    end
  end
end
