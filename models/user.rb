class User < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:name, :username, :email, :password]
		validates_format /\A.*@.*\..*\z/, :email, message: 'Error'
		errors.add(:name, 'cannot be empty') if !name || name.empty?
	end
	many_to_many :documents
	set_primary_key :id
end