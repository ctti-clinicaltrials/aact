Warden::Manager.after_set_user do |user, auth, opts|
  # create database account for the user if this is their first sign in
  user.add if user.sign_in_count == 0
end
