require 'sinatra/base'
require 'sinatra/reloader'
require 'bunny'
require 'dalli'
require 'json'
require 'pusher'

# %%demo

class DelayedWebRequest < Sinatra::Base

  def self.set_session_secret # Keep this above its invocation.
    s = ENV['SESSION_SECRET']
    raise if s.nil? || ''==s
    set :session_secret, s
  end

## Tilt.register :'html.erb', Tilt[:erb]

  set :erb, :layout => :'layout.html'

  configure do
    enable :dump_errors
    enable :lock
    enable :logging
    enable :raise_errors
    enable :sessions

    disable :protection
    disable :threaded
    set_session_secret
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

  get '/demo' do
    b, q = set_up_amqp
    payload = pop_message q
    s = 'queue_empty'
    if s == payload
      @amqp_message = s
    else
      data = ::JSON.parse payload
      set_up_memcachier
      pusher_channel = data['pusher_channel']
      @amqp_message  = data['message']
      set_up_pusher pusher_channel
    end
    close_amqp_connection b
    erb :'demo.html'
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

  def amqp_url
    # 'amqp://guest:guest@disk30:5672'
    ENV['CLOUDAMQP_URL']
  end

  def binding_key
    # 'delayed-webrequest'
    # ''
    'test1'
  end

  def close_amqp_connection(b)
    b.stop
  end

  def create_or_access_queue(b)
    q = b.queue queue_name
#    q = b.queue queue_name,
#        :binding_key => binding_key
    raise 'q is nil' if q.nil?
    q
  end

  def exchange_name
    # 'com.herokuapp.delayed-webrequest.exchange'
    default_exchange_name = '' # Binds to all queues.
  end

  def open_amqp_connection
    u = amqp_url
    raise 'u is nil' if u.nil?
    o = { \
          :logfile => 'log/bunny.log', # Not on Heroku.
          :logging => true
        }
#   b = ('' == u) ? (Bunny.new o) : (Bunny.new u, o)
    b = Bunny.new u
    b.start # Does not return b. 
    b
  end

  def pop_message(q)
    q.pop[:payload].to_s
  end

  def queue_name
    # 'com.herokuapp.delayed-webrequest.queue'
    # ''
    'test1'
  end

  def refresh_user_name
    @user_name = session[:user_name]
  end

  def set_up_amqp
    b = open_amqp_connection
    q = create_or_access_queue b

    e = use_exchange b
    [b, q]
  end

  def set_up_memcachier
    c=Dalli::Client.new ENV['MEMCACHIER_SERVERS' ], {
        :username    => ENV['MEMCACHIER_USERNAME'],
        :password    => ENV['MEMCACHIER_PASSWORD']  }
    c.set 'foo', 'Hello from Sinatra app (Memcachier)'
  end

  def set_up_pusher(channel)
    Pusher.app_id = ENV['PUSHER_APP_ID']
    Pusher.key    = ENV['PUSHER_KEY'   ]
    Pusher.secret = ENV['PUSHER_SECRET']
    Pusher[channel].trigger 'updates_ready', :message => 'Hello from Sinatra app (Pusher)'
  end

  def use_exchange(b)
    b.exchange exchange_name
  end

end
