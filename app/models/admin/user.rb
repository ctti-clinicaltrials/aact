require 'active_support/all'
module Admin
    # do i need these above?

    # class Admin::User < ApplicationRecord
    class Admin::User < Admin::AdminBase
        def self.admin_emails
            # query goes here
        end
    end

end
