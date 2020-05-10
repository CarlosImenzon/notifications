Sequel.migration do 
	up do
		add_column :documents, :id,
		add_column :documents, :title, null:false
		add_column :documents, :topic, null:false
		add_column :documents, :tag, null:false
	end

	down do 
		drop_column :documents, :id
		drop_column :documents, :title
		drop_column :documents, :topic
		drop_column :documents, :tag
	end

end