require 'sinatra/base'
require 'json'
require './models/init.rb'
require './models/user.rb'
require 'date'
require 'net/http'
require 'sinatra'
require 'sinatra-websocket'

# clase principal
class App < Sinatra::Base
  configure :development do
    enable :logging
    enable :session
    set :session_secret, 'Secreto'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  use DocumentController
  
  include FileUtils::Verbose

  before do
    @path = request.path_info
    if !session[:user_id] && @path != '/login' && @path != '/signup'
      redirect '/login'
    elsif session[:user_id]
      @user = User.find(id: session[:user_id])
    end
  end

  # get del index principal.
  get '/' do
    if !request.websocket?
      erb :index
    else
      notification
    end
  end

  # get del login para iniciar sesion.
  get '/login' do         # si se inicia sesion entra a la aplicacion,
    if session[:user_id]  # de lo contrario vuelve a solicitar los datos.
      redirect '/'
    else
      erb :login
    end
  end

  # get del logout para terminar la sesion.
  get '/logout' do
    session.clear
    erb :logout
  end

  # get para registrar un nuevo usuario.
  get '/signup' do
    if session[:user_id]
      session.clear
    else
      erb :signup
    end
  end

  # Cargar un nuevo documento, solo administrador.
  get '/save_document' do
    if !request.websocket?
      if session[:user_id] && @user.admin == 1
        @users = User.order(:username)
        erb :save_document
      end
    else
      notification
    end
  end

  # Get para mostrar los documentos
  get '/documents' do
    if request.websocket?
      notification
    elsif session[:user_id] && @user.admin == 1
      @documents = Document.all
      erb :documents
    else
      @documents = @user.documents
      erb :documents
    end
  end

  # get para cambiar la contrasena de un usuario.
  get '/change_pass' do
    erb :change_pass
  end

  # get para cambiar el mail de un usuario.
  get '/change_mail' do
    erb :change_mail
  end

  # get para ver el perfil de un usuario.
  get '/profile' do
    if !request.websocket?
      erb :profile
    else
      notification
    end
  end

  # post para loguear un usuario.
  post '/login' do
    @user = User.find(username: params[:username])
    if @user && @user.password == params['password']
      # Si los campos son correctos ingresa.
      session[:user_id] = @user.id
      redirect '/'
    elsif params[''] == ''
      # Si algun campo esta vacio, muestra error.
      @error = 'Verifique, campo/s vacio/s'
      erb :login
    else
      @error = 'Su username o email ya existe'
      erb :login
    end
  end

  # post para registrar un usuario.
  post '/signup' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    user = User.new(params_user)
    if user.valid? # Si los parametros son validos se registra el usuario.
      user.save
      erb :login
    elsif params[''] == '' # Si hay datos invalidos, muestra error.
      @error = 'Verifique, campo/s vacio/s'
      erb :signup
    else
      @error = 'Su username o email ya existe'
      erb :signup
    end
  end

  # post para cargar un nuevo documento
  post '/save_document' do
    File.chmod(0o777, 'public/')
    if !params[:fileInput].nil?
      @filename = params[:fileInput][:filename]
      file = params[:fileInput][:tempfile]
    else
      @filename = nil
    end
    document = Document.new(params_doc)
    if document.valid? && !@filename.nil? # Si el documento es valido se guarda
      document.save
      tagusers = params['multi_select']
      tagusers.each do |u| # Etiqueta de usuarios
        Relation.new(document_id: document.id, user_id: u.to_i).save
      end
      cp(file.path, "public/#{document.id}#{document.file}")
      File.chmod(0o777, "public/#{document.id}#{document.file}")
      redirect '/'
    else
      @error = 'Error al cargar documento, verifique los campos'
      @users = User.order(:username)
      erb :save_document
    end
  end

  # Post para cambiar la contrasena de usuario.
  post '/change_pass' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    # Verifica que la contrasena y la confirmacion sean iguales
    if params['password1'] != params['password2']
      @error = 'Las contraseñas no coinciden'
      erb :change_pass
    elsif @user.update(password: params['password1'])
      session.clear	# se cierra la sesion
      erb :login
    else
      @error = 'Error al cambiar contraseña o ingresaste la misma contraseña'
      erb :change_pass
    end
  end

  # Post para cambiar el mail del usuario.
  post '/change_mail' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    # Verifica que el correo nuevo y la confirmacion sean iguales
    if params['email1'] != params['email2']
      @error = 'Los email no coinciden'
      erb :change_mail
    elsif @user.update(email: params['email1'])
      erb :profile
    else
      @error = 'Error al cambiar email o ingresaste el mismo email'
      erb :change_mail
    end
  end

  # Post de borrado logico de un documento
  post '/delete_doc' do
    doc_id = params['delete_doc']
    suppress_doc(Document.find(id: doc_id)) unless doc_id.nil?
    halt :ok
  end

  # Funcion para el borrado logico de un documento
  def suppress_doc(document)
    document.update(visibility: false)	# Cambio de visibilidad del documento
  end

  # Funcion para la notificacion en tiempo real
  def notification
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      notifications
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end

  # Refactorizacion de notificacion
  def notifications
    ws.onmessage do |msg|
      EM.next_tick do
        settings.sockets.each do |s|
          s.send(msg)
        end
      end
    end
  end

  # Pasaje de parametros a signup
  def params_user
    {
      name: params['name'],
      email: params['email'],
      username: params['username'],
      password: params['password'],
      admin: 0
    }
  end

  # Pasaje de parametros a save_document
  def params_doc
    {
      title: params['title'],
      topic: params['topic'],
      file: @filename
    }
  end
end
