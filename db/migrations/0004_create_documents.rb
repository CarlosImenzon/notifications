Sequel.migration do 
	up do
		add_column :documents, :id,
		add_column :documents, :title, null:false
		add_column :documents, :topic, null:false
	end

	down do 
		drop_column :documents, :id
		drop_column :documents, :title
		add_column :documents, :topic
	end

end