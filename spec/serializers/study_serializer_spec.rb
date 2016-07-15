require 'rails_helper'

RSpec.describe StudySerializer, type: :serializer do
  before do
    xml = File.read(Rails.root.join(
      'spec',
      'support',
      'xml_data',
      'example_study.xml'
    ))

    @xml_record = StudyXmlRecord.create(content: xml, nct_id: 'NCT00002475')
    client = ClinicalTrials::Client.new
    client.populate_studies
  end

  let(:resource) { Study.last }

  it_behaves_like 'a serialized study'
end
