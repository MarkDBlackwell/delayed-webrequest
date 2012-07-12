require 'sinatra/base'
require 'sinatra/reloader'
require 'bunny'
require 'dalli'

# require 'memcachier' # As of July 12, 2012 not working (v 0.0.1).
require 'pusher'

class DelayedWebRequest < Sinatra::Base

#  set :cache, (Dalli::Client.new 'localhost:11211')
#  set :cache, (Dalli::Client.new '127.0.0.1:11211')
#  set :cache, (Dalli::Client.new '127.0.0.1:11211', :username => 'mark', :password => '')
#  set :enable_cache, true

  configure :development do
    Sinatra::Application.reset!    
    register Sinatra::Reloader
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

  get '/pusher' do
    set_up_pusher
  end

  get '/amqp' do
    set_up_amqp
#    'trying amqp' + @bunny_queue.pop[:payload].to_s
    @bunny_queue.pop[:payload].to_s
    'trying amqp'
  end

  get '/mem' do
    set_up_memcachier
    'ran memcachier'
  end

  get '/' do
    set_home
    erb :'index.html'
  end

#-------------
  protected

  def set_up_pusher
    Pusher.app_id = ENV['PUSHER_APP_ID']
    Pusher.key    = ENV['PUSHER_KEY']
    Pusher.secret = ENV['PUSHER_SECRET']
    Pusher['test_channel'].trigger 'greet', :greeting => 'Hello from set_up_pusher in Sinatra app'
    'Pushed to pusher'
  end

  def set_up_amqp
    u = ENV['CLOUDAMQP_URL']
    halt if u.nil? || ''==u
#    b = Bunny.new u
    b = Bunny.new
    b.start # Does not return b.
    @bunny_queue = b.queue 'test1'
    b.exchange('').publish 'Hello from set_up_amqp', :key => 'test1'
  end

  def set_up_memcachier
#    Rails.cache.write 'foo', 'Hello from set_up_memcachier in Sinatra app'
#    cache = Dalli::Client.new 'localhost:11211'
#    settings.cache.set 'foo', 'Hello from set_up_memcachier in Sinatra app'
    c=Dalli::Client.new
    c.set 'foo', 'Hello from set_up_memcachier in Sinatra app'
  end

  def version
    '0.0.0'
  end

  def site_name
    'Delayed Web Request'
  end

  def set_home
    @version        =  version
    @site_name      =  site_name
    @owner_name     = 'Mark D. Blackwell'
    @copyright_year = '2012'
    @blog_post_url  = 'http://markdblackwell.blogspot.com/2012/07/manage-long-running-external-webservice.html'
    @user_name      = 'Rails developer'
  end

end

