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

  get "/logout" do
    session.clear
    erb :logout
  end

  get "/signup" do
     if session[:user_id]
        session.clear
      else
        erb :signup
      end 
  end

  get "/save_document" do
    if session[:user_id]
      @users = User.order(:username)
      erb :document
    end
  end

  get "/documents" do
      @documents = @user.documents
      erb :documents
  end


  post '/login' do
    @user = User.find(username: params[:username])
    if @user && @user.password == params['password']
      session[:user_id] = @user.id
      redirect '/'
      else 
        @error ="Su nombre o contraseña es incorrecto"
        erb :login
      end
  end


  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"], admin: 0)
    if  user.save
      erb :login
    else
      [500, {}, "Internal Server Error"]
       erb :signup
    end
  end                                                          
  
  post '/save_document' do
    @filename = params[:fileInput][:filename]
    file = params[:fileInput][:tempfile]
    document = Document.create(title: params["title"], topic: params["topic"], file: @filename)
    if document.save
      tagusers = params["multi_select"]
      tagusers.each do |u|
        Relation.new(document_id: document.id, user_id: u.to_i).save
      end
      cp(file.path, "public/#{document.id}#{document.file}")
      "Documento cargado"
      redirect '/'
    else
      [500, {}, "Internal Server Error"]
      erb :document
    end
  end
end

