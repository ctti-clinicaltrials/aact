require 'rails_helper'

RSpec.describe UseCase, type: :model do

  before :each do
    @file = Rack::Test::UploadedFile.new('spec/support/xml_data/example_study.xml', 'text/xml')
  end

  it "should create use_case with multiple attachments" do
    status='proposed'
    title='use case title'
    bs='a brief summary'
    url='www.duke.edu'
    email='joe.smith@duke.edu'
    expect(UseCase.count).to eq(0)
    uc=UseCase.create({:status=>status,:title=>title,:brief_summary=>bs,:url=>url,:file=>@file})
    expect(UseCase.count).to eq(0)
    uc.email=email
    uc.save!
    expect(UseCase.count).to eq(1)
    expect(uc.attachments.size).to eq(1)
    expect(uc.attachment.file_name).to eq('example_study.xml')
    expect(uc.attachment.content_type).to eq('text/xml')
  end

end
