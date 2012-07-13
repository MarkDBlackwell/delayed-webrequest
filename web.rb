require 'sinatra/base'
require 'sinatra/reloader'
require 'bunny'
require 'dalli'
require 'memcachier'
require 'pusher'

class DelayedWebRequest < Sinatra::Base

  s = ENV['SESSION_SECRET']
  raise if s.nil? || ''==s
  set :session_secret, s

## Tilt.register :'html.erb', Tilt[:erb]
  set :erb, :layout => :'layout.html'

  configure do
    enable :dump_errors
    enable :lock
    enable :logging
    enable :raise_errors
    enable :sessions

    disable :threaded
  end

  configure :development do
    Sinatra::Application.reset!    
    register Sinatra::Reloader
  end

  before do
    @copyright_year = '2012'
    @owner_name     = 'Mark D. Blackwell'
    @site_name      = 'Delayed WebRequest'
    @version        = '0.0.0'
    refresh_user_name
  end

  get '/all' do
    s = set_up_amqp
    set_up_memcachier
    set_up_pusher
    erb s
  end

  get '/demo' do
    erb "Nothing here yet."
  end

  get '/hello' do
    s = @user_name
    s = s.nil? ? 'World' : s
    erb "Hello, #{ s } (from #{site_name} v#{version})!"
  end

  get '/login' do
    session[:user_name] = params[:name]
    refresh_user_name
    if ''==@user_name
      erb 'Error: name cannot be blank (see address bar).'
    else
      erb "Nothing here yet."
    end
  end

  get '/logout' do
    session[:user_name] = nil
    refresh_user_name
    erb "Logged out."
  end

  get '/' do
    erb :'welcome.html'
  end

#-------------
  protected

  def refresh_user_name
    @user_name = session[:user_name]
  end

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
    return 'u is nil' if u.nil?
    my_queue_name = 'test1'
    default_exchange_name = '' # Binds to all queues.
    my_exchange_name = default_exchange_name

    b = Bunny.new u
    b.start # Does not return b. Start a connection to AMQP.

    q = b.queue my_queue_name # Create or access the queue.
    raise 'q is nil' if q.nil?

    e = b.exchange my_exchange_name # Use a direct exchange.
    s = 'From amqp: ' + q.pop[:payload].to_s
    b.stop # Close the connection to AMQP.
    s
  end

  def set_up_memcachier
    c=Dalli::Client.new 'localhost:11211'
    c.set 'foo', 'Hello from Sinatra app, set_up_memcachier'
  end

  def set_up_pusher
    Pusher.app_id = ENV['PUSHER_APP_ID']
    Pusher.key    = ENV['PUSHER_KEY'   ]
    Pusher.secret = ENV['PUSHER_SECRET']
    Pusher['test_channel'].trigger 'greet', :greeting => 'Hello from Sinatra app, set_up_pusher'
  end

end

