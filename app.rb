require 'sinatra/base'
require 'json'
require './models/init.rb'
require './models/user.rb'
require 'date'
require 'net/http'
require 'sinatra'
require 'sinatra-websocket'


include FileUtils::Verbose

class App < Sinatra::Base
  configure :development do
    enable :logging
    enable :session
    set :session_secret, "Secreto"
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  before do
    @path = request.path_info
    if !session[:user_id] && @path != '/login' && @path != '/signup'
      redirect '/login'
      elsif session[:user_id]
        @user = User.find(id: session[:user_id])
    end
  end

  get '/' do
    if !request.websocket?
      erb:index
    else
      notification
    end
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
    if !request.websocket?
      if session[:user_id] && @user.admin == 1
        @users = User.order(:username)
        erb :save_document
      end
    else
      notification
    end
  end

  get "/documents" do
    if !request.websocket?
      if session[:user_id] && @user.admin == 1
        @documents = Document.all
        erb :documents
      else
        @documents = @user.documents
        erb :documents
      end
    else
      notification
    end
  end

  get "/change_pass" do
    erb :change_pass
  end

  get "/change_mail" do
    erb :change_mail
  end

  get "/profile" do
    if !request.websocket?
      erb :profile
    else
      notification
    end
  end

  post '/login' do
    @user = User.find(username: params[:username])
    if @user && @user.password == params['password']
      session[:user_id] = @user.id
      redirect '/'
      else
       if params[""]=""   
        @error ="Verifique, campo/s vacio/s"
        erb :login
      else  
        @error ="Su username o email ya existe"
        erb :login
      end
    end
  end

  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"], admin: 0)
    if  user.valid?
      user.save  
      erb :login
      elsif params[""]=""   
        @error ="Verifique, campo/s vacio/s"
        erb :signup
      else  
        @error ="Su username o email ya existe"
        erb :signup
      end
    
  end

  post '/save_document' do
    File.chmod(0777, "public/")
    if params[:fileInput] != nil
      @filename = params[:fileInput][:filename]
      file = params[:fileInput][:tempfile]
    else
      @filename = nil
    end
    document = Document.new(title: params["title"], topic: params["topic"], file: @filename)
    if document.valid? && @filename != nil
      document.save
      tagusers = params["multi_select"]
      tagusers.each do |u|
        Relation.new(document_id: document.id, user_id: u.to_i).save
      end
      cp(file.path, "public/#{document.id}#{document.file}")
      File.chmod(0777, "public/#{document.id}#{document.file}")
      "Documento cargado"
      redirect '/'
    else
      @error ="Error al cargar documento, verifique los campos"
      @users = User.order(:username)
      erb :save_document
    end
  end

  post '/change_pass' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    if params["password1"] != params["password2"]
      @error ="Las contraseñas no coinciden"
      erb :change_pass
    else
      if @user.update(password: params["password1"])
        session.clear
        erb :login
      else
        @error ="Error al cambiar contraseña o ingresaste la misma contraseña"
        erb :change_pass
      end
    end
  end

  post '/change_mail' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    if params["email1"] != params["email2"]
      @error ="Los email no coinciden"
      erb :change_mail
    else
      if @user.update(email: params["email1"])
        erb :profile
      else
        @error ="Error al cambiar email o ingresaste el mismo email"
        erb :change_mail
      end
    end
  end

  post '/delete_doc' do
    doc_id = params["delete_doc"]
    if !doc_id.nil?
      suppress_doc(Document.find(id: doc_id))
    end
    halt :ok
  end

  def suppress_doc(document)
      document.update(visibility: false)
  end

  def notification
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick {
          settings.sockets.each{|s|
            s.send(msg)
          }
        }
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
  
end
