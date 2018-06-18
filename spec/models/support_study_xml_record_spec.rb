require 'rails_helper'

describe Support::StudyXmlRecord do
  describe 'associations' do
    it { should belong_to(:study) }
  end
end
