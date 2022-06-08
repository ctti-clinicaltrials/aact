module Admin
    class User < Admin::AdminBase
        self.table_name = "users"
        def self.admin_emails
            where(admin:true).map {|user| user.email}
        end
    end
end
