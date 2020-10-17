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

  get "/login" do         #get del login si inicia sesion entra a la aplicación,
    if session[:user_id]  #de lo contrario vuelve a solicitar los datos.
      redirect '/'
    else
      erb :login
    end
  end

  get "/logout" do    #get del logout para terminar la sesión.
    session.clear
    erb :logout
  end

  get "/signup" do    #get para registrar un nuevo usuario.
    if session[:user_id]
      session.clear
    else
      erb :signup
    end
  end

  get "/save_document" do   #get para cargar un nuevo documento si es usuario administrador.
    if !request.websocket?
      if session[:user_id] && @user.admin == 1
        @users = User.order(:username)
        erb :save_document
      end
    else
      notification
    end
  end

  get "/documents" do       #get para mostrar todos los documentos a un usuario administrador.
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

  get "/change_pass" do   #get para cambiar la contraseña de un usuario.
    erb :change_pass
  end

  get "/change_mail" do   #get para cambiar el mail de un usuario.
    erb :change_mail
  end

  get "/profile" do       #get para ver el perfil de un usuario.
    if !request.websocket?
      erb :profile
    else
      notification
    end
  end

  post '/login' do                                    #post para loguear un usuario.
    @user = User.find(username: params[:username])
    if @user && @user.password == params['password']  #Si los campos son correctos ingresa.
      session[:user_id] = @user.id
      redirect '/'
      else
       if params[""]=""   
        @error ="Verifique, campo/s vacio/s"          #Si algun campo esta vacio, muestra error.  
        erb :login
      else  
        @error ="Su username o email ya existe"
        erb :login
      end
    end
  end

  post '/signup' do                             #post para registrar un usuario.
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"], admin: 0)
    if  user.valid?                                   #Si los parametros son validos se registra el usuario.
      user.save  
      erb :login
      elsif params[""]=""                             #Si hay datos invalidos, muestra error.
        @error ="Verifique, campo/s vacio/s"
        erb :signup
      else  
        @error ="Su username o email ya existe"
        erb :signup
      end
    
  end

  post '/save_document' do                #post para cargar un nuevo documento
    File.chmod(0777, "public/")
    if params[:fileInput] != nil
      @filename = params[:fileInput][:filename]
      file = params[:fileInput][:tempfile]
    else
      @filename = nil
    end
    document = Document.new(title: params[params_doc)
    if document.valid? && @filename != nil   #Si el documento es valido se guarda
      document.save
      tagusers = params["multi_select"]
      tagusers.each do |u|                  #Etiqueta de usuarios
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

  post '/change_pass' do                    #Post para cambiar la contraseña de usuario.
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    if params["password1"] != params["password2"]	#Verifica que la contraseña y la confirmacion sean iguales
      @error ="Las contraseñas no coinciden"
      erb :change_pass
    else
      if @user.update(password: params["password1"])
        session.clear	#se cierra la sesion
        erb :login
      else
        @error ="Error al cambiar contraseña o ingresaste la misma contraseña"
        erb :change_pass
      end
    end
  end

  post '/change_mail' do  				#Post para cambiar el mail del usuario.
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    if params["email1"] != params["email2"]	#Verifica que el correo nuevo y la confirmacion sean iguales
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

  post '/delete_doc' do  			#Post de borrado logico de un documento  
    doc_id = params["delete_doc"]
    if !doc_id.nil?
      suppress_doc(Document.find(id: doc_id))
    end
    halt :ok
  end

  def suppress_doc(document)		#Funcion para el borrado logico de un documento
      document.update(visibility: false)	#Cambio de visibilidad del documento
  end

  def notification					#Funcion para la notificacion en tiempo real
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
  
  #Pasaje de parametros a save_document
  def params_doc
    {
      title: params['title'],
      topic: params['topic'],
      file: @filename
    }
  end

end
