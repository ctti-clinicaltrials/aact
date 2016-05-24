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

  describe '#get_studies' do
    context 'success' do
      before do
        VCR.use_cassette('get_studies') do
          client.get_studies
        end
      end

      it 'should grab the xml' do
        expect(client.files.first).to include('xml')
      end

      it 'should create a load event' do
        load_event = ClinicalTrials::LoadEvent.last

        expect(load_event.present?).to eq(true)
        expect(load_event.load_time.present?).to eq(true)
      end

    end

    context 'failure'
  end

  describe '#populate_studies' do
    context 'success' do
      before do
        client.populate_studies(studies)
      end

      it 'should create a study record' do
        expect(Study.last.nct_id).to eq('NCT00002475')
      end

      it 'should create a load event' do
        load_event = ClinicalTrials::LoadEvent.last

        expect(load_event.present?).to eq(true)
        expect(load_event.load_time.present?).to eq(true)
        expect(load_event.new_studies).to eq(1)
      end

    end

    context 'failure' do
      context 'duplicate study' do
        it 'should not create a new study' do
          existing_study = Study.new({
            xml: Nokogiri::XML(studies[0]),
            nct_id: client.send(:extract_nct_id_from_study, studies[0])
          }).create

          allow(client).to receive(:get_studies) { studies }

          duplicate_studies = client.get_studies
          client.populate_studies(duplicate_studies)

          expect(Study.all.count).to eq(1)
        end
      end
    end

  end

end
