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

    # first and last name missing
    find('input[name="commit"]').click
    expect(page).to have_content "First name can't be blank"
    expect(page).to have_content "Last name can't be blank"

    # first & last names too long
    long_name = "s" * 129
    fill_in 'user_first_name', with: long_name
    fill_in 'user_last_name', with: long_name
    find('input[name="commit"]').click
    expect(page).to have_content "First name is too long (maximum is 100 characters)"
    expect(page).to have_content "Last name is too long (maximum is 100 characters)"
    expect(page).not_to have_content "First name can't be blank"
    expect(page).not_to have_content "Last name can't be blank"

    # valid first & last names
    fill_in 'user_first_name', with: 'Fname'
    fill_in 'user_last_name', with: 'Lname'
    find('input[name="commit"]').click
    expect(page).not_to have_content "First name can't be blank"
    expect(page).not_to have_content "Last name can't be blank"
    expect(page).not_to have_content "First name is too long (maximum is 100 characters)"
    expect(page).not_to have_content "Last name is too long (maximum is 100 characters)"

    # email, username & password missing
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Username can't be blank"
    fill_in 'user_email', with: 'Fname.Lname@gmail.com'
    fill_in 'user_username', with: 'username'
    find('input[name="commit"]').click
    expect(page).not_to have_content "Email can't be blank"
    expect(page).not_to have_content "Username can't be blank"

    # password too short
    expect(page).to have_content "Password can't be blank"
    fill_in 'user_password', with: 'pw'
    fill_in 'user_password_confirmation', with: 'pw'
    find('input[name="commit"]').click
    expect(page).to have_content "Password is too short (minimum is 3 characters)"
    expect(page).not_to have_content "Password can't be blank"

    # password too long
    long_pwd = "0" * 129
    fill_in 'user_password', with: long_pwd
    fill_in 'user_password_confirmation', with: long_pwd
    find('input[name="commit"]').click
    expect(page).to have_content "Password is too long (maximum is 128 characters)"

    # mismatch of password & confirmation password
    fill_in 'user_password', with: 'pwd'
    fill_in 'user_password_confirmation', with: 'pw'
    find('input[name="commit"]').click
    expect(page).to have_content "Password confirmation doesn't match Password"
    fill_in 'user_password', with: 'pwd'
    fill_in 'user_password_confirmation', with: 'pwd'
    find('input[name="commit"]').click
    expect(page).not_to have_content "Password confirmation doesn't match Password"

    # invalid username
    fill_in 'user_username', with: 'x'
    find('input[name="commit"]').click
    expect(page).to have_content "Username is too short (minimum is 3 characters)"
    fill_in 'user_username', with: '1ax'
    find('input[name="commit"]').click
    expect(page).not_to have_content "Username is too short (minimum is 3 characters)"
    expect(page).to have_content "Username must start with an alpha character"
    fill_in 'user_username', with: 'axaa@'
    find('input[name="commit"]').click
    expect(page).to have_content "Username cannot contain special chars"
    expect(page).not_to have_content "Username is too short (minimum is 3 characters)"
    expect(page).not_to have_content "Username must start with an alpha character"
    fill_in 'user_username', with: 'ausername'
    find('input[name="commit"]').click
    expect(page).not_to have_content "Username cannot contain special chars"

    # db is unaccessible
    Util::DbManager.new.revoke_db_privs
    find('input[name="commit"]').click
    expect(page).to have_content "Sorry AACT database is temporarily unavailable"
    Util::DbManager.new.grant_db_privs
    #expect(page).not_to have_content "Sorry AACT database is temporarily unavailable"

  end

end
