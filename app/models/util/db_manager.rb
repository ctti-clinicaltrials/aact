module Util
  class DbManager

    def self.public_db_name
      'aact'
    end

    def self.change_password(user,pwd)
      begin
        con=ActiveRecord::Base.establish_connection(:public).connection
        con.execute("alter user #{user.db_username} password '#{pwd}'")
        con.disconnect!
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def self.add_user(user)
      begin
        con=ActiveRecord::Base.establish_connection(:public).connection
        con.execute("create user #{user.db_username} password '#{user.unencrypted_password}'")
        con.execute("grant connect on database aact to #{user.db_username}")
        con.execute("grant usage on schema public TO #{user.db_username}")
        con.execute("grant select on all tables in schema public to #{user.db_username};")
        con.disconnect!
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def self.remove_user(user)
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.execute("drop owned by #{user.db_username};")
      con.execute("revoke all on schema public from #{user.db_username};")
      con.execute("drop user #{user.db_username};")
      con.disconnect!
    end

    def self.revoke_db_privs
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.execute("revoke connect on database #{public_db_name} from aact;")
      con.execute("revoke select on all tables in schema public from aact;")
      con.execute("revoke all on schema public from aact;")
      con.disconnect!
    end

    def self.grant_db_privs
      self.revoke_db_privs
      con=ActiveRecord::Base.establish_connection(:public).connection
      # some of this seems redundant & better placed in revoke_db_privs, but the following works to allow aact user to
      # select from tables, but not update the tables nor create new tables
      con.execute("grant connect on database #{public_db_name} to aact;")
      con.execute("grant usage on schema public TO aact;")
      con.execute('grant select on all tables in schema public to aact;')
      con.disconnect!
    end

  end

end
