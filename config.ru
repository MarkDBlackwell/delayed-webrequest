# Rackup version:

# run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello world (from Rack)!\n")] }

# Sinatra version:

require './web'

run Sinatra::Application
