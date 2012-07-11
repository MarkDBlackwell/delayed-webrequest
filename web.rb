#!/usr/bin/env ruby

require 'sinatra/base'

class DelayedWebRequest < Sinatra::Base

# Start the server if ruby file executed directly
  run! :port => 5000, :server => 'webrick' if app_file == $0

  get '/hello/:name' do
    "Hello, #{params[:name]} (from #{site_name} v#{version})!"
  end

  get '/hello' do
    "Hello, world2 (from #{site_name} v#{version})!"
  end

  get '/login' do
    "nothing here yet."
  end

  get '/' do
    set_home
    erb :'index.html'
  end

#-------------
  protected

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
