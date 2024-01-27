require 'rails_helper'

describe PendingResult do
  it 'should test documents_data' do
    expected_data = {
      nct_id: 'NCT03453554',
      event: 'RELEASE',
      event_date_description: '2022-12-23',
      event_date: Date.parse('2022-12-23')
    }

    hash = JSON.parse(File.read('spec/support/json_data/NCT03453554.json'))
    json = StudyJsonRecord::ProcessorV2.new(hash)
    result = PendingResult.mapper(json)

    expect(result.first).to eq(expected_data)
  end
end
