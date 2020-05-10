require 'json'
require './models/init.rb'
require './models/user.rb'

class App < Sinatra::Base
 

  get "/" do 
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

  post '/login' do
    user = User.find(username: params[:username])
    if user && user.password == params[:password]
        session[:id] = user.id
        erb :login
        #redirect "/"
      else
        @error ="Your username o password is incorrect"
        erb :login
      end
  end

  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    # User.create(name: name)
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"])
    if user.save
      "USER CREATED"
       erb :signup
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
  end
end

