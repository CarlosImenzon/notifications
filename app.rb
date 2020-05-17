require 'sinatra/base'
require 'json'
require './models/init.rb'
require './models/user.rb'
require 'date'
require 'net/http'

include FileUtils::Verbose
class App < Sinatra::Base

  configure :development do
  enable :logging
  enable :session
  set :session_secret, "Secreto"
  set :sessions, true
  end

   before do 
    @path = request.path_info
    if !session[:user_id] && @path != '/login' && @path != '/signup'
      redirect '/login'
    elsif session[:user_id]
      @user = User.find(id: session[:user_id])
    end
  end

  get "/" do
    erb :index
  end

  get "/login" do
    if session[:user_id]
      redirect '/'
    else
      erb :login
    end
  end   

  get "/signup" do
    if session[:user_id]
      session.clear
    end
    erb :signup
  end 

  get "/document" do
    if session[:user_id]
      erb :document
    end
  end

  get "/documents" do
      @documents = Document.all 
      erb :documents
  end


  post '/login' do
    usuario = User.find(username: params[:username])
    if usuario && usuario.password == params['password']
      session[:user_id] = usuario.id
      redirect '/'
      else
        redirect '/signup'
        [400, {"Content-Type" => "text/plain"}, ["Unautorized"]]
      end
  end


  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    # User.create(name: name)
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"])
    if  user.save
      erb :login
    else
      [500, {}, "Internal Server Error"]
       erb :signup
    end
  end


  post '/document' do
  	request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    document = Document.new(title: params["title"], topic: params["topic"], tag: params["tag"])
    if document.save
      "Documento cargado"
      redirect '/'
    else
      [500, {}, "Internal Server Error"]
      erb :document
    end
  end
end

