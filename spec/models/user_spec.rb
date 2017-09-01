require 'rails_helper'

describe User do

  it "adds user by creating row in Users table & creating a db account for the user" do
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'first.last@duke.edu',:password=>'aact')
    user.save!
    user.add
    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    # user can access the public database
    con=ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      database: 'aact',
      username: user.db_username
    ).connection
    expect(con.active?).to eq(true)
    con.disconnect!
    expect(con.active?).to eq(false)

    user.remove
    expect(User.count).to eq(0)
    # user can no longer access the public database
    begin
      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        database: 'aact',
        username: user.db_username
      ).connection
    rescue => e
      expect(e.class).to eq(ActiveRecord::NoDatabaseError)
    end
  end
end
