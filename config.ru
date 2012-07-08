# Rackup version:

# run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello World!\n")] }

# Sinatra version:

require './hello'
run Sinatra::Application
