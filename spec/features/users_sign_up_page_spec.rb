require 'rails_helper'

feature "Users Sign Up Page" do

  scenario "sign up - verify new user validations" do
    visit '/users/sign_up'
    expect(page).to have_title "AACT Database | Clinical Trials Transformation Initiative"
    expect(page).to have_field 'user_first_name'
    expect(page).to have_field 'user_last_name'
    expect(page).to have_field 'user_email'
    expect(page).to have_field 'user_username'
    expect(page).to have_selector("input[type=submit][value='Sign up']")

    valid_first_name = 'Fname'
    valid_last_name = 'Lname'
    valid_email = 'first.last@gmail.com'
    valid_username='ausername'
    valid_password='pwd'
    db_mgr = Util::UserDbManager.new
    db_mgr.remove_user(valid_username)

    # Start fresh - make sure user is gone
    user=User.where('username=?',valid_username).first
    user.remove if user
    expect(db_mgr.user_account_exists?(valid_username)).to eq(false)

    # first and last name missing
    expect(db_mgr.user_account_exists?(valid_username)).to eq(false)
    submit
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)
    expect(page).to have_content "First name can't be blank"
    expect(page).to have_content "Last name can't be blank"
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # first & last names too long
    long_name = "s" * 129
    fill_in 'user_first_name', with: long_name
    fill_in 'user_last_name', with: long_name
    submit
    expect(page).to have_content "First name is too long (maximum is 100 characters)"
    expect(page).to have_content "Last name is too long (maximum is 100 characters)"
    expect(page).not_to have_content "First name can't be blank"
    expect(page).not_to have_content "Last name can't be blank"
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # valid first & last names
    fill_in 'user_first_name', with:valid_first_name
    fill_in 'user_last_name', with: valid_last_name
    submit
    expect(page).not_to have_content "First name can't be blank"
    expect(page).not_to have_content "Last name can't be blank"
    expect(page).not_to have_content "First name is too long (maximum is 100 characters)"
    expect(page).not_to have_content "Last name is too long (maximum is 100 characters)"
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # email, username & password missing
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Username can't be blank"
    fill_in 'user_email', with: valid_email
    fill_in 'user_username', with: valid_username
    submit
    expect(page).not_to have_content "Email can't be blank"
    expect(page).not_to have_content "Username can't be blank"
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # password too short
    expect(page).to have_content "Password can't be blank"
    fill_in 'user_password', with: 'pw'
    fill_in 'user_password_confirmation', with: 'pw'
    submit
    expect(page).to have_content "Password is too short (minimum is 3 characters)"
    expect(page).not_to have_content "Password can't be blank"
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # password too long
    long_pwd = "0" * 129
    fill_in 'user_password', with: long_pwd
    fill_in 'user_password_confirmation', with: long_pwd
    submit
    expect(page).to have_content "Password is too long (maximum is 128 characters)"
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # mismatch of password & confirmation password
    fill_in 'user_password', with: 'pwd'
    fill_in 'user_password_confirmation', with: 'pw'
    submit
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # invalid username
    fill_in 'user_username', with: 'x'
    submit
    expect(page).to have_content "Username is too short (minimum is 3 characters)"
    fill_in 'user_username', with: '1ax'
    submit
    expect(page).not_to have_content "Username is too short (minimum is 3 characters)"
    expect(page).to have_content "Username must start with an alpha character"
    fill_in 'user_username', with: 'axaa@'
    submit
    expect(page).to have_content "Username cannot contain special chars"
    expect(page).not_to have_content "Username is too short (minimum is 3 characters)"
    expect(page).not_to have_content "Username must start with an alpha character"
    fill_in 'user_username', with: valid_username
    submit
    expect(page).not_to have_content "Username cannot contain special chars"
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # db is inaccessible
    Util::DbManager.new.revoke_db_privs
    expect(Util::DbManager.new.public_db_accessible?).to eq(false)
    submit
    expect(page).to have_content "Sorry AACT database is temporarily unavailable"
    Util::DbManager.new.grant_db_privs
    expect(Util::DbManager.new.public_db_accessible?).to eq(true)
    submit
    expect(page).not_to have_content "Sorry AACT database is temporarily unavailable"
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(false)

    # successful create - all valid values
    fill_in 'user_password', with: valid_password
    fill_in 'user_password_confirmation', with: valid_password
    expect(UserMailer).to receive(:report_user_event).exactly(Notifier.admin_addresses.size).times
    submit

    expect(page).to have_content "A message with a confirmation link has been sent to your email address"
    expect(Util::UserDbManager.new.user_account_exists?(valid_username)).to eq(true)
    user=User.where('username=?',valid_username).first
    expect(user.email).to eq(valid_email)
    expect(user.first_name).to eq(valid_first_name)
    expect(user.last_name).to eq(valid_last_name)

    visit "/users/confirmation?confirmation_token=#{user.confirmation_token}"
    expect(page).to have_content "logged in as #{valid_first_name} #{valid_last_name}"
    expect(page).to have_content "Edit Profile"
    expect(page).to have_content "Sign out"
    click_on 'Edit Profile'
    expect(page).to have_content "Sign out"
    expect(page).to have_field 'user_first_name'
    expect(page).to have_field 'user_last_name'
    expect(page).to have_field 'user_password'
    expect(page).to have_field 'user_password_confirmation'
    expect(page).to have_field 'user_current_password'

    visit '/users/edit'
    new_first_name='new first name'
    fill_in 'user_first_name', with: new_first_name
    fill_in 'user_current_password', with: valid_password
    fill_in 'user_password', with: ''
    fill_in 'user_password_confirmation', with: ''
    expect(UserMailer).to receive(:report_user_event).exactly(1).times
    submit
    user=User.where('username=?',valid_username).first
    expect(user.first_name).to eq(new_first_name)

    user.remove
    expect(User.where('username=?',valid_username).size).to eq(0)
    expect(Util::UserDbManager.new.user_account_exists?(user.username)).to eq(false)
  end

end
