class User < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:name, :username, :email, :password]
		validates_unique [:username]
		validates_unique [:email]
		validates_format /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :email
	end
	many_to_many :documents
	one_to_many :relations

end