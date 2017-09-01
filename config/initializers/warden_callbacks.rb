Warden::Manager.after_set_user do |user, auth, opts|
  if user.sign_in_count == 0
    con=ActiveRecord::Base.establish_connection('public').connection
    con.execute("create user #{user.db_username}")
    con.execute("grant connect on database aact to #{user.db_username}")
    con.execute("grant usage on schema public TO #{user.db_username}")
    con.execute("grant select on all tables in schema public to #{user.db_username};")
  end
end
