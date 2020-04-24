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
    if  params[:email] == "Carlos"
        params[:password] == "1234" 
      "Correcto" 
    else 
        @error = 'Usuario o contraseña incorrectos'
        erb :login
    end
  end


  post '/signup' do
    user = User.new(name: params["fullname"], email: params["email"], password: params["password"])
    if user.save
      redirect "/"
    else 
      [500, {}, "Internal server Error"]
    end 
  end



end 