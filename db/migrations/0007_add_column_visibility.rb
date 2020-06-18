Sequel.migration do 
	up do
		add_column :documents, :visibility, "boolean"
		set_column_default :documents, :visibility, true
	end

	down do 
		drop_column :documents, :visibility
	end
end