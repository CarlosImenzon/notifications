require 'json'
require './models/init.rb'

class App < Sinatra::Base
 
  get "/" do 
    erb :docs
  end
  get "/login" do
    erb :login

  end   
  get "/signup" do
    erb :signup 
  end 

  post '/login' do
    if  params[:username]
        params[:password] 
      "Correcto" 
    else 
        @error = 'Usuario o contraseña incorrectos'
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
    else
      [500, {}, "Internal Server Error"]
    end
  end
end

