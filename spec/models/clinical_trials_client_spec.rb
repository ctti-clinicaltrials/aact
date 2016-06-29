require 'rails_helper'

describe ClinicalTrials::Client do
  let(:search_term) { 'duke lupus rheumatoid arthritis' }
  let(:expected_url) { 'https://clinicaltrials.gov/search?term=duke+lupus+rheumatoid+arthritis&resultsxml=true' }
  let(:stub_request_headers) { {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'} }

  subject { described_class.new(search_term: search_term) }

  let(:zipped_studies) { File.read(Rails.root.join('spec','support','xml_data','download_xml_files.zip')) }
  let(:raw_study_xml_1) { File.read(Rails.root.join('spec','support','xml_data','NCT00513591.xml')) }
  let(:official_study_title_1) { 'Duke Autoimmunity in Pregnancy Registry' }
  let(:raw_study_xml_1_mod) { File.read(Rails.root.join('spec','support','xml_data','NCT00513591_mod.xml')) }
  let(:official_study_title_1_mod) { 'This Is An Updated Title' }
  let(:raw_study_xml_1_mod_date) { 'June 15, 2016' }

  let(:study_xml_nct_ids) { ["NCT00513591", "NCT00482794"] }
  let(:study_xml_official_title) { [official_study_title_1, official_study_title_2] }
  let(:study_xml_official_title_mod) { [official_study_title_1_mod, official_study_title_2] }
  let(:study_xml_official_title) { ["Duke Autoimmunity in Pregnancy Registry", "Genetics of Antiphospholipid Antibody Syndrome"] }

  let(:study_xml_record) { StudyXmlRecord.create(content: raw_study_xml_1, nct_id: "NCT00513591") }

  let(:raw_study_xml_2) { File.read(Rails.root.join('spec','support','xml_data','NCT00482794.xml')) }
  let(:official_study_title_2) { 'Genetics of Antiphospholipid Antibody Syndrome' }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      expect(subject.url).to eq(expected_url)
    end

    it 'should set the processed_studies' do
      expect(subject.url).to eq(expected_url)
    end
  end

  describe '#download_xml_files' do
    before do
      stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => zipped_studies, :headers => {})
    end

    it 'should create a study xml record and load event' do
      expect {
        expect {
          subject.download_xml_files
        }.to change{StudyXmlRecord.count}.by(2)
      }.to change{ClinicalTrials::LoadEvent.count}.by(1)

      study_xml_record_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      Nokogiri::XML(study_xml_record_1.content).xpath('//clinical_study').xpath('lastchanged_date').text
      expect(study_xml_record_1).to be

      raw_xml_content = Nokogiri::XML(raw_study_xml_1).child.to_xml
      existing_xml_content = Nokogiri::XML(study_xml_record_1.content).child.to_xml
      expect(existing_xml_content).to eq(raw_xml_content)

      load_event = ClinicalTrials::LoadEvent.first
      expect(load_event.event_type).to eq('get_studies')
    end
  end

  describe '#create_study_xml_record(xml)' do
    it 'should create a study xml record' do
      subject.create_study_xml_record(raw_study_xml_1)
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      expect(study_xml_record_1).to be

      processed_studies = {
        updated_studies: [],
        new_studies: ["NCT00513591"]
      }
      expect(subject.processed_studies).to eq(processed_studies)

      subject.create_study_xml_record(raw_study_xml_1_mod)
      processed_studies = {
        updated_studies: ["NCT00513591"],
        new_studies: ["NCT00513591"]
      }
      expect(subject.processed_studies).to eq(processed_studies)
      expect(StudyXmlRecord.count).to eq(1)

      study_xml_record_1_mod = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      official_title = Nokogiri::XML(study_xml_record_1_mod.content)
        .xpath('//clinical_study')
        .xpath('official_title').text
      expect(official_study_title_1_mod).to eq(official_title)

      subject.create_study_xml_record(raw_study_xml_2)
      processed_studies = {
        updated_studies: ["NCT00513591"],
        new_studies: ["NCT00513591", "NCT00482794"]
      }
      expect(subject.processed_studies).to eq(processed_studies)

      subject.create_study_xml_record(raw_study_xml_1_mod)
      expect(subject.processed_studies).to eq(processed_studies)
      expect(StudyXmlRecord.count).to eq(2)
    end
  end
end