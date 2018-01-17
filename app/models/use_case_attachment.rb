class UseCaseAttachment < Admin::AdminBase
  belongs_to :use_case

  def self.create_from(file,image_type=nil)
    new({:file_name=>sanitize_filename(file.original_filename),
         :content_type=>file.content_type,
         :file_contents=>file.read,
         :is_image=>!image_type.nil?
        })
  end

  def renderable
    Base64.encode64(file_contents)
  end

  def remove_previously_stored_files_after_update
  end

  private

  def self.sanitize_filename(file_name)
    return File.basename(file_name)
  end

end
