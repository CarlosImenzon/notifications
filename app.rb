require 'json'
require './models/init.rb'
class App < Sinatra::Base
 

  get "/login" do
    erb :login
  end 
   
  get "/signup" do
    erb :signup 
  end 

   get "/" do 
    erb :docs
  end

  post '/login' do
    if  param[:username] =='Juan' 
        param[:password] =='123'
      "Correcto" 
    else 
        @error = 'Usuario o contraseña incorrectos'
        erb :login
    end
  end

  post '/signup' do
    user = User.new(name: param["name"], email: param["email"], username: param["username"], password: param["password"])
    if user.save
      redirect "/"
    else 
    end 
  end
end

