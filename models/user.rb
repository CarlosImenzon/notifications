class User < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:name, :username, :email, :password]
		#nombre y mail unicos
		validates_format /\A.*@.*\..*\z/, :email
	end
	many_to_many :documents
	set_primary_key :id
end