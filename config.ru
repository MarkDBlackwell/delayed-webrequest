# Rackup version:

# run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello World (from Rack)!\n")] }

# Sinatra version:

require './hello'
run Sinatra::Application
