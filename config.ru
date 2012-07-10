# Rackup version:
# run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello world (from Rack)!\n")] }

# Sinatra version, classic style:
# require './web'
# run Sinatra::Application

# Sinatra version, modular style:

require './web'

run DelayedWebRequest

