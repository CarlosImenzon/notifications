Sequel.migration do 
	up do
		add_column :documents, :tag, String
	end

	down do 
		drop_column :documents, :tag
	end

end