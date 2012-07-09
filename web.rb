require 'sinatra'

get '/hello/:name' do
  "Hello, #{params[:name]} (from Sinatra3)!"
end

get '/' do
  'Hello, world (from Sinatra2)!'
end
