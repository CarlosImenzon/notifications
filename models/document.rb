class Document < Sequel::Model
  def to_api
    {
    	id: id,
    	title: title,
    	topic: topic      
    }
  end
end