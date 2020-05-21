require File.expand_path '../../test_helper.rb', __FILE__

class UserTest < Minitest::Unit::TestCase
	MiniTest::Unit::TestCase
	def test_name_existence
		# Arrange
		@user = User.new
		# Act
		@user.name = nil
		# Assert
		assert_equal @user.valid?, false
	end

  	def test_create_user 
    	@user  = User.create(name: "carlos",password: "123456", username: "imenzon",email: "c@gmail.com", admin: 0)
    	assert_equal @user.valid?, true
  	end

  	def test_create_user_presence_name
   		u  = User.new(password: "1234", username: "juan",email: "c@gmail.com")
    	assert_equal u.valid?, false
  	end

  	def test_create_user_presence_email
   		u  = User.new(password: "1234", username: "Fede",name: "Memedetto")
    	assert_equal u.valid?, false
  	end

  	def test_validate_email 
    	@user  = User.new(name: "carlos",password: "1234", username: "sosa",email: "cgmail.com")
    	assert_equal @user.valid?, false
  	end

  	def test_validate_email_ 
    	@user  = User.new(name: "carlos",password: "1234", username: "carlos1997",email: "cgmail.com")
    	assert_equal @user.valid?, false
  	end  	
end