require 'sinatra/base'
require 'sinatra/reloader'
require 'bunny'
require 'dalli'
require 'memcachier' # As of July 12, 2012 not working (v 0.0.1).
require 'pusher'

class DelayedWebRequest < Sinatra::Base

  configure do
    enable :dump_errors
    enable :lock
    enable :logging
    enable :raise_errors

    disable :threaded
  end

  configure :development do
    Sinatra::Application.reset!    
    register Sinatra::Reloader
  end

  get '/all' do
    s = set_up_amqp
    set_up_memcachier
    set_up_pusher
##  'Ran all'
    s
  end

  get '/amqp' do
    set_up_amqp
    return '@bunny_queue is nil' if @bunny_queue.nil?
##  'From amqp: ' + @bunny_queue.pop[:payload].to_s
    'Ran amqp'
  end

  get '/hello/:name' do
    "Hello, #{params[:name]} (from #{site_name} v#{version})!"
  end

  get '/hello' do
    "Hello, world2 (from #{site_name} v#{version})!"
  end

  get '/login' do
    "nothing here yet."
  end

  get '/mem' do
    set_up_memcachier
    'ran memcachier'
  end

  get '/pusher' do
    set_up_pusher
    'Pushed to pusher'
  end

  get '/' do
    set_home
    erb :'index.html'
  end

#-------------
  protected

  def set_home
    @version        =  version
    @site_name      =  site_name
    @owner_name     = 'Mark D. Blackwell'
    @copyright_year = '2012'
    @blog_post_url  = 'http://markdblackwell.blogspot.com/2012/07/manage-long-running-external-webservice.html'
    @user_name      = 'Rails developer'
  end

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
    return 'u is nil' if u.nil?
    my_queue_name = 'test1'
    default_exchange_name = '' # Binds to all queues.
    my_exchange_name = default_exchange_name

    b = Bunny.new
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

  def site_name() 'Delayed Web Request' end

  def version() '0.0.0' end

end

