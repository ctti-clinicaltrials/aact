require 'spec_helper'
require 'rails_helper'

describe PagesController do
  describe "GET #pipe_files" do
    it "sets inst var daily_files & archive_files" do
      flat_file_set = [{:name=>'file_name.zip', :date_created=>'20180410', :size=>760, :url=>'/static/pipe-delimited-export.zip'}]
      allow_any_instance_of(Util::FilePresentationManager).to receive(:daily_flat_files).and_return(flat_file_set)
      allow_any_instance_of(Util::FilePresentationManager).to receive(:monthly_flat_files).and_return(flat_file_set)
      get :pipe_files
      expect(assigns(:daily_files).size).to eq(1)
      expect(assigns(:daily_files).first[:name]).to eq('file_name.zip')
      expect(assigns(:archive_files).size).to eq(1)
      expect(assigns(:archive_files).first[:name]).to eq('file_name.zip')
      expect(response).to have_http_status(:ok)
    end
  end

end
