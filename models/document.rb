class Document < Sequel::Model
	plugin :validation_helpers
    def validate
    	super
        	validates_presence [:title, :topic]
        	validates_unique [:title]
  		end
		many_to_many  :users
		one_to_many :relations
end