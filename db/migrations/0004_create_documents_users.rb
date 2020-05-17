Sequel.migration do
	up do
		create_table(:documents_users) do
		  foreign_key :document_id, :documents 
		  foreign_key :user_id, :users 
		  primary_key [:document_id, :user_id]
		  index [:document_id, :user_id]
	 	end
 	end
	 down do
		 drop_table :users
	 end
end