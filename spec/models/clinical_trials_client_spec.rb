require 'rails_helper'

describe ClinicalTrials::Client do
  let(:search_term) { 'duke lupus rheumatoid arthritis' }
  let(:expected_url) { 'https://clinicaltrials.gov/search?term=duke+lupus+rheumatoid+arthritis&resultsxml=true' }
  let(:stub_request_headers) { {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'} }

  subject { described_class.new(search_term: search_term) }

  let(:zipped_studies) { File.read(Rails.root.join('spec','support','xml_data','download_xml_files.zip')) }

  let(:raw_study_xml_1) { File.read(Rails.root.join('spec','support','xml_data','NCT00513591.xml')) }
  let(:study_xml_download_date_text_1) { 'ClinicalTrials.gov processed this data on June 27, 2016' }
  let(:official_study_title_1) { 'Duke Autoimmunity in Pregnancy Registry' }
  let(:study_last_changed_date_1) { 'June 14, 2016' }
  let(:study_nct_id_1) { 'NCT00513591' }

  let(:raw_study_xml_2) { File.read(Rails.root.join('spec','support','xml_data','NCT00482794.xml')) }
  let(:official_study_title_2) { 'Genetics of Antiphospholipid Antibody Syndrome' }
  let(:study_nct_id_2) { 'NCT00482794' }

  let(:raw_study_xml_1_mod) { File.read(Rails.root.join('spec','support','xml_data','NCT00513591_mod.xml')) }
  let(:official_study_title_1_mod) { 'This Is An Updated Title' }
  let(:study_last_changed_date_1_mod) { 'June 15, 2016' }

  let(:raw_study_xml_redownload_1) { File.read(Rails.root.join('spec','support','xml_data','NCT00513591_redownloaded.xml')) }
  # let(:study_xml_redownload_date_text_1) { 'ClinicalTrials.gov processed this data on June 29, 2016' }

  let(:study_xml_nct_ids) { [study_nct_id_1, study_nct_id_2] }
  let(:study_xml_official_titles) { [official_study_title_1, official_study_title_2] }
  let(:study_xml_official_titles_mod) { [official_study_title_1_mod, official_study_title_2] }

  let(:study_xml_record) { StudyXmlRecord.create(content: raw_study_xml_1, nct_id: "NCT00513591") }

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

      processed_studies = {
        updated_studies: [],
        new_studies: ["NCT00513591"]
      }
      expect(subject.processed_studies).to eq(processed_studies)

      study_xml_record_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      expect(study_xml_record_1).to be
    end

    it 'should update the study xml record changed' do
      expect {
        subject.create_study_xml_record(raw_study_xml_1)
        subject.create_study_xml_record(raw_study_xml_1_mod)
      }.to change{StudyXmlRecord.count}.by(1)

      processed_studies = {
        updated_studies: ["NCT00513591"],
        new_studies: []
      }
      expect(subject.processed_studies).to eq(processed_studies)

      study_xml_record_1_mod = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      updated_official_title = Nokogiri::XML(study_xml_record_1_mod.content)
        .xpath('//official_title').text
      expect(updated_official_title).to eq(official_study_title_1_mod)
    end

    it 'should create or update the study xml record changed' do
      expect {
        subject.create_study_xml_record(raw_study_xml_1)
        subject.create_study_xml_record(raw_study_xml_1_mod)
        subject.create_study_xml_record(raw_study_xml_2)
      }.to change{StudyXmlRecord.count}.by(2)

      processed_studies = {
        updated_studies: ["NCT00513591"],
        new_studies: ["NCT00482794"]
      }
      expect(subject.processed_studies).to eq(processed_studies)

      subject.create_study_xml_record(raw_study_xml_1_mod)
      expect(subject.processed_studies).to eq(processed_studies)
    end

    it 'should not update the study xml record if download_date is the only change' do
      subject.create_study_xml_record(raw_study_xml_1)
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      expect(study_xml_record_1).to be

      download_date_text_1 = Nokogiri::XML(study_xml_record_1.content)
        .xpath('//download_date').text
      expect(download_date_text_1).to eq(study_xml_download_date_text_1)

      subject.create_study_xml_record(raw_study_xml_redownload_1)
      study_xml_record_redownloaded_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
      redownload_date_text_1 = Nokogiri::XML(study_xml_record_redownloaded_1.content)
        .xpath('//download_date').text
      expect(redownload_date_text_1).to eq(study_xml_download_date_text_1)
    end
  end

  describe '#populate_studies' do
    before do
      stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => zipped_studies, :headers => {})
      subject.download_xml_files
    end

    it 'should create studies from an existing study xml records' do
      subject.populate_studies
      study_1 = Study.find_by(nct_id: study_nct_id_1)
      expect(study_1.last_changed_date_str).to eq(study_last_changed_date_1)

      expect(Study.pluck(:nct_id)).to match_array(study_xml_nct_ids)
      expect(StudyXmlRecord.pluck(:nct_id)).to match_array(study_xml_nct_ids)
      expect(Study.pluck(:official_title)).to match_array(study_xml_official_titles)

      subject.create_study_xml_record(raw_study_xml_1_mod)
      subject.populate_studies
      expect(Study.pluck(:official_title)).to match_array(study_xml_official_titles_mod)

      study_1_mod = Study.find_by(nct_id: study_nct_id_1)
      expect(study_1_mod.last_changed_date_str).to eq(study_last_changed_date_1_mod)
      expect(study_1.last_changed_date_str).not_to eq(study_1_mod.last_changed_date_str)
    end
  end

  describe '#import_xml_file(study_xml, benchmark: false)' do
    before do
      stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => zipped_studies, :headers => {})
      subject.download_xml_files
    end

    it 'should create a study from an existing study xml record' do
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id: study_nct_id_1)
      expect(study_xml_record_1).to be_truthy
      expect(Study.count).to be(0)

      subject.import_xml_file(study_xml_record_1.content)
      study_1 = Study.find_by(nct_id: study_nct_id_1)
      expect(study_1).to be_truthy
      expect(Study.count).to be(1)
    end

    it 'should update an existing study from an updated study xml record' do
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id: study_nct_id_1)
      subject.import_xml_file(study_xml_record_1.content)
      expect(Study.count).to be(1)
      study_1 = Study.find_by(nct_id: study_nct_id_1)
      expect(study_1.official_title).to eq(official_study_title_1)

      subject.import_xml_file(raw_study_xml_1_mod)
      study_1_mod = Study.find_by(nct_id: study_nct_id_1)
      expect(study_1_mod.last_changed_date_str).to eq(study_last_changed_date_1_mod)
      expect(study_1_mod.official_title).to eq(official_study_title_1_mod)
      expect(Study.count).to be(1)
    end

    it 'should create a load event if benchmark is true' do
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id: study_nct_id_1)
      expect {
        subject.import_xml_file(study_xml_record_1.content, benchmark: true)
      }.to change{ClinicalTrials::LoadEvent.count}.by(1)

      last_load_event = ClinicalTrials::LoadEvent.last
      expect(last_load_event.event_type).to eq('get_studies')
      expect(last_load_event.status).to eq('complete')
      expect(last_load_event.load_time).not_to be_nil
    end

    it 'should not create a load event if benchmark is nil or false' do
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id: study_nct_id_1)

      expect {
        subject.import_xml_file(study_xml_record_1.content)
      }.to change{ClinicalTrials::LoadEvent.count}.by(0)

      expect {
        subject.import_xml_file(study_xml_record_1.content, benchmark: false)
      }.to change{ClinicalTrials::LoadEvent.count}.by(0)
    end
  end
end
