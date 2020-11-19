require './models/user.rb'
require './models/document.rb'

include FileUtils::Verbose


class Document_Service


  def self.new_document(title, topic, file)
    document = Document.new(title: title, topic:topic, file: file)
     if document.valid? && !@filename.nil? # Si el documento es valido se guarda
        document.save
        tagusers = params['multi_select']
        tagusers.each do |u| # Etiqueta de usuarios
        Relation.new(document_id: document.id, user_id: u.to_i).save
      end
        cp(file.path, "public/#{document.id}#{document.file}")
        File.chmod(0o777, "public/#{document.id}#{document.file}")
        redirect '/'
      else
        @error = 'Error al cargar documento, verifique los campos'
        @users = User.order(:username)
      end
  end

  def self.delete_doc(doc_id)
    suppress_doc(Document.find(id: doc_id)) unless doc_id.nil?
    halt :ok
  end

  # Funcion para el borrado logico de un documento
  def self.suppress_doc(document)
    document.update(visibility: false)	# Cambio de visibilidad del documento
  end
end