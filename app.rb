require 'json'
require './models/init.rb'

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

  get "/documents" do
    @documents = Document.all 
    erb :documents
  end

  post '/login' do
    user = User.find(username: params[:username])
    if user && user.password == params[:password]
        session[:id] = user.id
        #redirect "/"
      else
        erb :login
        @error ="Tu usuario o contraseña son incorrectos"
      end
  end


  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    # User.create(name: name)
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"])
    if  user.valid?
       user.save
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
    if document.save
      "Documento cargado"
    else
      [500, {}, "Internal Server Error"]
      erb :document
    end
  end
end

