class UseCaseAttachmentsController < ApplicationController

  def show
    @attachment=UseCaseAttachment.find(params['id'])
    send_data(@attachment.file_contents,
             type: @attachment.content_type,
             filename: @attachment.file_name,
             disposition: 'inline',
             )
  end
end

