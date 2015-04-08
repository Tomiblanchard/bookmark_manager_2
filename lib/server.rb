require 'sinatra/base'
require 'data_mapper'
require 'tag'
require 'user'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'
DataMapper.finalize
DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base


  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    tags = params["tags"].split(" ").map do |tag|
      Tag.first_or_create(:text => tag)
    end
    url = params["url"]
    title = params["title"]
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    User.create(email: params[:email],
                password: params[:password])
    redirect to('/')
  end

  run! if app_file == $PROGRAM_NAME
end
