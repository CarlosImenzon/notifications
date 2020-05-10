Sequel.migration do 
	up do 
		create_table(:documents) do
			#primary_key :id
			String 		:title,	null: false
			String		:topic, null: false
			#String  	:tag, null: false
		end
	end
	down do
		drop_table(:documents)
	end		
end