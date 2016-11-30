class UseCase < ActiveRecord::Base
  has_many :use_case_attachments

  def attachments
    use_case_attachments
  end

end
