require 'json'
require './models/init.rb'
require './models/user.rb'

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
    user = User.find(username: params[:username])
    if user && user.password == params[:password]
        session[:id] = user.id
        erb :login
        #redirect "/"
      else
        @error ="Your username o password is incorrect"
        erb :login, :layout => :layout
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
end

