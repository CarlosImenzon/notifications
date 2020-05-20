Sequel.migration do 
	up do
		drop_column :documents, :tag
	end

	down do 
		add_column :documents, :tag, String
	end

end