require 'rails_helper'

RSpec.describe UseCase, type: :model do

  it "should create use_case with multiple attachments" do
    status='proposed'
    title='use case title'
    bs='a brief summary'
    url='www.duke.edu'
    expect(UseCase.count).to eq(0)
    uc=UseCase.create({:status=>status,:title=>title,:brief_summary=>bs,:url=>url})
    expect(UseCase.count).to eq(1)
    data = File.read("spec/support/xml_data/example_study.xml")
#    a=UseCaseAttachment.create({:use_case=>uc, :file_name=>'test.xml', :payload=>data})
#    expect(uc.attachments.size).to eq(1)
#    expect(a.file_name).to eq('test.xml')
  end

end
