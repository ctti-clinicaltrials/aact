require 'rails_helper'

describe Util::FileManager do
  context 'create static db copy' do
    it 'should not display files that are not downloadable zip files' do
      dir_name="#{Rails.public_path}/static/tmp/static_copies"
      FileUtils.remove_dir(dir_name) if File.exists?(dir_name)
      FileUtils.mkdir_p(dir_name)
      allow_any_instance_of(Util::FileManager).to receive(:static_copies_directory).and_return(dir_name)
      fm=Util::FileManager.new

      good_file_name="#{fm.static_copies_directory}/20180404_clinical_trials.zip"
      good_file=File.new(good_file_name,"w")
      expect(File).to exist(good_file)

      bad_file_name="#{fm.static_copies_directory}/.nfs00000001c324f8c500000001"
      bad_file=File.new(bad_file_name,"w")
      expect(File).to exist(bad_file)
      FileUtils.remove_dir(dir_name)
    end

  end

end
