class UseCaseAttachment < AdminBase
  belongs_to :use_case

  def self.create_from(file)
    new({:file_name=>sanitize_filename(file.original_filename),
         :content_type=>file.content_type,
         :file_contents=>file.read
        })
  end

  private

  def self.sanitize_filename(file_name)
    return File.basename(file_name)
  end

end
