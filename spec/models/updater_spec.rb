require 'rails_helper'
require 'securerandom'

describe ClinicalTrials::Updater do

  describe '#update_studies' do
    before do
      Study.all.each { |study|
        StudyXmlRecord.create(content: "<study><nct_id>#{study.nct_id}</nct_id></study>", nct_id: study.nct_id) }
    end

    context 'given an array of nct_ids' do
      xit 'should re-create all of the specified studies' do
        # this was too contrived to mean anything.  need to stub #update_studies method
        nct_ids = ['NCT00023673','NCT00482794','NCT00513591','NCT00734539','NCT00980226','NCT01076361','NCT01207388','NCT01341288','NCT01642004','NCT01841593','NCT02028676','NCT02317510',]
        created_at_dates = Study.pluck(:created_at)

        allow_any_instance_of(ClinicalTrials::Client).to receive(:download_xml_files) do
          nct_ids.each do |id|
            StudyXmlRecord.where(nct_id: id).first_or_create(content: "<study><nct_id>#{id}</nct_id></study>")
          end
        end

        updater = described_class.new
        updater.update_studies(nct_ids)

        old_studies_are_gone = (Study.pluck(:created_at) & created_at_dates).length == 0

        expect(Study.count).to eq(12)
        expect(nct_ids).to include(Study.first.nct_id)
      end
    end
  end

end
