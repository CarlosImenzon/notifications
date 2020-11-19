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
  require './controllers/documentController.rb'
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
  use DocumentController

  # get del index principal.(Listo)
  get '/' do
    if !request.websocket?
      erb :index
    else
      notification
    end
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

end
