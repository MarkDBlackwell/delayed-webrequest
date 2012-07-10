require 'sinatra'

def version
  '0.0.0'
end

def site_name
  'Delayed Web Request'
end

# set :public_folder, File.dirname(__FILE__) + '/resolved'


get '/hello/:name' do
  "Hello, #{params[:name]} (from Sinatra v#{version})!"
end

get '/hello' do
  "Hello, world (from Sinatra v#{version})!"
end

get '/' do
  @version = version
  @user_name = 'mark'
  @copyright_year = '2012'
  @site_name = site_name
  @blog_post_url = 'http://markdblackwell.blogspot.com/2012/07/manage-long-running-external-webservice.html'
  @body_text = "We offer a way to scale Rails apps using "\
      "RabbitMQ, Memcache and PusherApp. "\
      "See <a href=\"#{
      @blog_post_url
      }\">this</a> blog post."
  erb :'index.html'
end
