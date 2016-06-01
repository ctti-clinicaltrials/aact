require 'rails_helper'

describe ClinicalTrials::Client do
  let(:client) { described_class.new(search_term: 'lacrosse') }
  let(:studies) { [File.read(Rails.root.join('spec',
                                             'support',
                                             'xml_data',
                                             'example_study.xml'))] }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      client = described_class.new(
        search_term: 'pancreatic cancer vaccine'
      )

      expect(client.url).to eq('https://clinicaltrials.gov/search?term=pancreatic+cancer+vaccine&resultsxml=true')
    end
  end

  describe '#import_xml_file' do
    let(:study) { studies.first }

    context 'success' do
      it 'should create study' do
        client.import_xml_file(study)

        expect(Study.all.count).to eq(1)
      end
    end

    context 'failure' do
      context 'duplicate study' do
        it 'should not create new study' do
          client.import_xml_file(study)
          client.import_xml_file(study)

          expect(Study.all.count).to eq(1)
        end

        context 'study has changed' do
          it 'should update study' do
            client.import_xml_file(study)
            doc = Nokogiri::XML(study)
            doc.xpath('//clinical_study').xpath('lastchanged_date').children.first.content = 'Jan 1, 2016'
            updated_study = doc.to_xml
            client.import_xml_file(updated_study)

            expect(Study.all.count).to eq(1)
            expect(Study.last.last_changed_date.to_s).to eq('2016-01-01')
          end
        end

      end
    end

  end

end
