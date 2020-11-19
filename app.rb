# clase principal
class App < Sinatra::Base

  require 'sinatra/base'
  require 'json'
  require './models/init.rb'
  require './models/user.rb'
  require 'date'
  require 'net/http'
  require 'sinatra'
  require 'sinatra-websocket'
  require './controllers/accountController.rb'
  include FileUtils::Verbose


  configure :development do
    enable :logging
    enable :session
    #set :sessionns_fail, '/'
    set :session_secret, 'Secreto'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  before do
    @user = User.find(id: session[:user_id])
    @path = request.path_info
    if !@user && @path != '/login' && @path != '/signup'
      redirect '/login'
    elsif @user 
      @user = User.find(id: session[:user_id])
    end
  end

  use AccountController

  # get del index principal.(Listo)
  get '/' do
    if !request.websocket?
      erb :index
    else
      notification
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

  # Funcion para la notificacion en tiempo real (Listo)
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

  # Pasaje de parametros a save_document
  def params_doc
    {
      title: params['title'],
      topic: params['topic'],
      file: @filename
    }
  end
end
