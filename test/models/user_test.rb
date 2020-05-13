require File.expand_path '../../test_helper.rb', __FILE__

class UserTest < Minitest::Unit::TestCase

	def test_name_existence
	# Arrange
	@user = User.new
	# Act
	@user.name = nil
	# Assert
	assert_equal @user.valid?, false
	end
end