module Util
  class DbManager

    def self.public_db_name
      'aact'
    end

    def self.add_user(user)
      begin
        con=ActiveRecord::Base.establish_connection(:public).connection
        con.execute("create user #{user.db_username}")
        con.execute("grant connect on database aact to #{user.db_username}")
        con.execute("grant usage on schema public TO #{user.db_username}")
        con.execute("grant select on all tables in schema public to #{user.db_username};")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def self.remove_user(user)
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.execute("drop owned by #{user.db_username};")
      con.execute("revoke all on schema public from #{user.db_username};")
      con.execute("drop user #{user.db_username};")
    end

    def self.revoke_db_privs
      con=ActiveRecord::Base.connection
      con.execute("revoke connect on database #{public_db_name} from aact;")
      con.execute("revoke select on all tables in schema public from aact;")
      con.execute("revoke all on schema public from aact;")
    end

    def self.grant_db_privs
      # some of this may seem redundant & better placed in revoke_db_privs, but the following works to allow aact user to
      # select from tables, but not update the tables nor create new tables
      self.revoke_db_privs
      con.execute("grant connect on database #{public_db_name} to aact;")
      con.execute("grant usage on schema public TO aact;")
      con.execute('grant select on all tables in schema public to aact;')
    end

  end

end
