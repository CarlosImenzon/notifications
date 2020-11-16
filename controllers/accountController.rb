require 'sinatra/base'
require 'json'
require './services/accountService'
require './exceptions/ValidationModelError.rb'
require 'sinatra/flash'

# controlador de la cuenta
class AccountController < Sinatra::Base

    configure :development do
        enable :logging
		enable :session
		set :views, settings.root + '/../views'
        set :session_secret, 'Secreto'
        set :sessions, true
    end

	before do
		@user = User.find(id: session[:user_id])
	end

	# Mostrar excepciones
	register Sinatra::Flash

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
		session.clear && @user
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

	post '/signup' do
		name = params[:name]
		email = params[:email]
		username = params[:username]
		password = params[:password]
		admin = 1
	
		# Invocamos al Modelo, para implementar la Logica de Negocio
		begin
		  AccountService.signup(name, email, username, password, admin)
		  redirect '/login'
		rescue ValidationModelError => e
			flash.now[:error_message] = e.message 
			return erb :signup
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

	# Post para cambiar la contrasena de usuario.
	post '/change_pass' do
		password1 = params['password1']
		password2 = params['password2']
		
		# Verifica que la contrasena y la confirmacion sean iguales
		begin
			AccountService.change_pass(password1, password2, @user)
			redirect '/logout'
		rescue ValidationModelError => e
			flash.now[:error_message] = e.message
			return erb :change_pass
		end
	end
	
	# Post para cambiar el mail del usuario.
	post '/change_mail' do
		email1 = params['email1']
		email2 = params['email2']
		
		# Verifica que la contrasena y la confirmacion sean iguales
		begin
			AccountService.change_mail(email1, email2, @user)
			redirect '/logout'
		  rescue ValidationModelError => e
			flash.now[:error_message] = e.message
			return erb :change_mail
		  end
	end

end
