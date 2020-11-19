require 'sinatra/base'
require './services/documentService.rb'
require 'json'
require 'sinatra/flash'
require './exceptions/ValidationModelError.rb'


include FileUtils::Verbose

class DocumentController < Sinatra::Base
  configure :development, :production do
    set :views, settings.root + '/../views'
  end 
  
  before do 
    @user = User.find(id: session[:user_id])
    @documents = Document.all
    @users = User.order(:username)
  end

  # Mostrar excepciones
	register Sinatra::Flash

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
  
   # post para cargar un nuevo documento
  post '/save_document' do
    title = params['title']
    topic = params['topic']
    #file = @filename
    File.chmod(0o777, 'public/')
    filename = params[:fileInput][:filename]
    file = params[:fileInput][:tempfile]
    tagusers = params['multi_select']
    begin
      if !file.nil?
        Document_Service.new_document(title, topic, file, tagusers)
        redirect '/'
      end
      rescue ValidationModelError => e
        flash.now[:error_message] = e.message
        return erb :save_document
    end
  end


  # Post de borrado logico de un documento
  post '/delete_doc' do
    doc_id = params['delete_doc']
    begin
      Document_Service.delete_doc(doc_id)
      flash.now[:error_message] = ''
      erb :documents
    rescue ValidationModelError => e
			flash.now[:error_message] = e.message
			return erb :documents
    end
  end
end