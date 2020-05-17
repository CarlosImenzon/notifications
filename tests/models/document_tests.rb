require File.expand_path '../../test_helper.rb', __FILE__

class DocumentTest < Minitest::Unit::TestCase
	MiniTest::Unit::TestCase
	def test_title_existence
		# Arrange
		@doc = Document.new
		# Act
		@doc.title = nil
		# Assert
		assert_equal @doc.valid?, false
	end

  def test_create_document
    @doc  = Document.new(title: "Computacin", topic: "Analisis")
    assert_equal @doc.valid?, true
  end

  def test_create_doc_presence_title
   	@doc  = Document.new(topic: "1234")
    assert_equal @doc.valid?, false
  end

  def test_create_doc_presence_topic
   	@doc  = Document.new(title: "Juancito2")
    assert_equal @doc.valid?, false
  end	
end