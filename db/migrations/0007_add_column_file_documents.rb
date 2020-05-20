Sequel.migration do 
	up do
		add_column :documents, :file, String
	end

	down do 
		drop_column :documents, :file
	end

end