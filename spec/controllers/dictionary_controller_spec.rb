require 'rails_helper'

RSpec.describe DictionaryController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      allow_any_instance_of(DictionaryController).to receive(:get_dictionary).and_return(Roo::Spreadsheet.open('spec/support/shared_examples/aact_data_definitions.xlsx'))
      get :show
      expect(response).to have_http_status(:success)
    end
  end

end
