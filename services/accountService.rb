class AccountService

	require './exceptions/ValidationModelError.rb'
	require './models/user.rb'

    def self.signup (name, email, username, password, admin)
		user = User.new(name: name, email: email, username: username, password: password, admin: admin)

        if user.valid? # Si los parametros son validos se registra el usuario.
			user.save
		# Si hay datos invalidos, muestra error.	
		elsif name == '' || email == '' || username == '' || password == '' || admin == ''
			raise ValidationModelError.new("Verifique, campo/s vacio/s",1)
		else
			raise ValidationModelError.new("Su username o email ya existe",1)
		end
    end

	def self.change_pass (password1, password2, currentUser)
		if password1 != password2
			raise ValidationModelError.new("Las contraseñas no coinciden",1)
		elsif currentUser.update(password: password1)
		else
			raise ValidationModelError.new("Error al cambiar contraseña o ingresaste la misma contraseña",1)
		end
	end

	def self.change_mail (email1, email2, currentUser)
		if email1 != email2
			raise ValidationModelError.new("Los email no coinciden",1)
		elsif currentUser.update(email: email1)
		else
			raise ValidationModelError.new("Error al cambiar email o ingresaste el mismo email",1)
		end
	end

end
