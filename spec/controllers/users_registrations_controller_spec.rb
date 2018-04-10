require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  describe "GET #create" do
    xit "returns http success" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      #allow_any_instance_of(Users::RegistrationsController).to receive(:create).and_return('sfsdf')
      get :create
      db_mgr=Util::UserDbManager.new({:load_event=>'stub'})
      expect(assigns(:db_mgr)).to eq(db_mgr)
      expect(response).to have_http_status(:ok)
    end
  end

end
