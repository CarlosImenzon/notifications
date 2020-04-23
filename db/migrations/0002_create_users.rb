Sequel.migration do 
	up do
		add_column :users, :email, String
		add_column :users, :username, String
		add_column :users, :password, String
	end

	down do 
		drop_column :users, :email
		drop_column :users, :username
		drop_column :users, :password
	end

end