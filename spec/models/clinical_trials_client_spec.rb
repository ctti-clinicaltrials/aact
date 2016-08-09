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

    context 'dry_run' do
      context 'default' do
        it 'should set dry_run to false' do
          expect(subject.dry_run).to be false
        end
      end

      context 'set in initialization' do
        let(:expected_dry_run) { true }
        subject { described_class.new(search_term: search_term, dry_run: expected_dry_run) }

        it 'should set dry_run' do
          expect(subject.dry_run).to be true
        end
      end
    end
  end

  describe '#download_xml_files' do
    before do
      stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => zipped_studies, :headers => {})
    end

    context 'default dry_run false' do
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

    context 'dry_run true' do
      subject { described_class.new(search_term: search_term, dry_run: true) }

      it 'should not create a study xml records or load events' do
        expect {
          expect {
            subject.download_xml_files
          }.not_to change{StudyXmlRecord.count}
        }.not_to change{ClinicalTrials::LoadEvent.count}
      end
    end
  end

  describe '#create_study_xml_record(xml)' do
    context 'default dry_run false' do
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

    end

    context 'dry_run true' do
      subject { described_class.new(search_term: search_term, dry_run: true) }

      it 'should report a study xml record' do
        expect {
          subject.create_study_xml_record(raw_study_xml_1)
        }.not_to change{StudyXmlRecord.count}

        processed_studies = {
          updated_studies: [],
          new_studies: ["NCT00513591"]
        }
        expect(subject.processed_studies).to eq(processed_studies)
      end

    end
  end

  describe '#populate_studies' do
    before do
      stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => zipped_studies, :headers => {})
      subject.download_xml_files
    end

    context 'default dry_run' do
      it 'should create studies from an existing study xml records' do
        subject.populate_studies
        study_1 = Study.find_by(nct_id: study_nct_id_1)
        expect(study_1.last_changed_date).to eq(study_last_changed_date_1.to_date)

        expect(Study.pluck(:nct_id)).to match_array(study_xml_nct_ids)
        expect(StudyXmlRecord.pluck(:nct_id)).to match_array(study_xml_nct_ids)
        expect(Study.pluck(:official_title)).to match_array(study_xml_official_titles)
      end
    end

    context 'dry_run true' do
      subject { described_class.new(search_term: search_term, dry_run: true) }

      it 'should return without running' do
        expect {
          subject.populate_studies
        }.not_to change{ ClinicalTrials::LoadEvent.count }
      end
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
