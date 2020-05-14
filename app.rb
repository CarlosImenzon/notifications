require 'sinatra/base'
require 'json'
require './models/init.rb'
require './models/user.rb'

class App < Sinatra::Base
  configure :development do
  enable :logging
  enable :session
  set :session_secret, “secret”
  set :sessions, true
  end

  get "/" do
    logger.info ""
    logger.info “session information”
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "--------------"
    logger.info ""
    erb :index
  end

  get "/login" do
    erb :login
  end   

  get "/signup" do
    erb :signup
  end 

  get "/document" do
  	erb :document
  end

  get "/documents" do
    @documents = Document.all 
    erb :documents
  end

  post '/login' do
    user = User.find(username: params[:username])
    if User.last.id
        #user && user.password == params[:password]
        session[:user.username] == user.last.username
        session[:user.name] == user.last.name
        session[:user.id] == user.last.id
        #redirect "/"
      else
        erb :login
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
    document = Document.new(title: params["title"], topic: params["topic"])
    if document.save
      "Documento cargado"
    else
      [500, {}, "Internal Server Error"]
      erb :document
    end
  end
end

