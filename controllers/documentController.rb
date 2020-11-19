require 'sinatra/base'
require './services/documentService'
require './models/user.rb'
require 'date'
require 'net/http'
require 'sinatra'
require 'sinatra-websocket'
require 'json'
require './models/init.rb'
require './models/document.rb'


include FileUtils::Verbose

class Document_Controller < Sinatra::Base
  configure :development, :production do
    set :views, settings.root + '/../views'
  end 
  
  before do 
    @user = User.find(id: session[:user_id])
    @documents = Document.all
    @users = User.order(:username)
  end


  # Get para mostrar los documentos
  get '/documents' do
    #if request.websocket?
    #  redirect back
    #els
    if session[:user_id] && @user.admin == 1
        erb :documents
    else
        documents = @user.documents
        erb :documents
    end
  end

  # Cargar un nuevo documento, solo administrador.
  get '/save_document' do
    if !request.websocket?
      if session[:user_id] && @user.admin == 1
        @users = User.order(:username)
        erb :save_document
      else
        erb :index
      end
    end
  end

   # post para cargar un nuevo documento
  post '/save_document' do
    title = params['title']
    topic = params['topic']
    file = @filename
    File.chmod(0o777, 'public/')
    filename = params[:fileInput][:filename]
    file = params[:fileInput][:tempfile]
    begin
      if !file.nil?
        Document_Service.new_document(title, topic, file)
      else
        @filename = nil
      end
      erb :save_document
    end
  end
    
  # Post de borrado logico de un documento
  post '/delete_doc' do
    doc_id = params['delete_doc']
    begin
      Document_Service.delete_doc(doc_id)
    end
  end
end