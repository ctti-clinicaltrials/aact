module DeviseHelper

  def devise_error_messages!
    flash_alerts = []
    error_key = 'errors.messages.not_saved'

    if !flash.empty?
      flash_alerts.push(flash[:error]) if flash[:error]
      flash_alerts.push(flash[:alert]) if flash[:alert]
      flash_alerts.push(flash[:notice]) if flash[:notice]
      error_key = 'devise.failure.invalid'
    end

    return "" if resource.errors.empty? && flash_alerts.empty?
    errors = resource.errors.empty? ? flash_alerts : resource.errors.full_messages
    if errors.size == 1
      messages = content_tag(:p,errors.first)
    else
      messages = errors.uniq.map { |msg| content_tag(:li, msg) }.join
    end

    html = <<-HTML
    <div id="errorExplanation">
      <p>#{messages}</p>
    </div>
    HTML

    html.html_safe
  end

end
