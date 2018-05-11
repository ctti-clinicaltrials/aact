module Admin
  class UserEvent < Admin::AdminBase

    def subject_line
      if event_type == 'backup'
        "AACT #{Rails.env.capitalize} User Backups"
      else
        "AACT #{Rails.env.capitalize} user #{event_type}: #{self.description}"
      end
    end

  end
end
