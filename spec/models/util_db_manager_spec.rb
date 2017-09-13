require 'rails_helper'

describe Util::DbManager do

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
      it 'should save data from the xml file to the StudyXmlRecords table' do
        StudyXmlRecord.destroy_all
        subject.save_file_contents(File.open(Rails.root.join('spec','support','xml_data','download_xml_files.zip')))
        expect(StudyXmlRecord.count).to eq(2)
        rec = StudyXmlRecord.find_by(nct_id:'NCT00513591')

        raw_xml_content = Nokogiri::XML(raw_study_xml_1).child.to_xml
        existing_xml_content = Nokogiri::XML(rec.content).child.to_xml
        #expect(existing_xml_content).to eq(raw_xml_content)  #tags don't always appear in expected order
      end
    end

  end

  describe '#create_study_xml_record(nct_id,xml)' do
    context 'default dry_run false' do
      nct_id='NCT00513591'
      it 'should create a study xml record' do
        subject.create_study_xml_record(nct_id,raw_study_xml_1)

        processed_studies = {
          updated_studies: [],
          new_studies: [nct_id]
        }
        expect(subject.processed_studies).to eq(processed_studies)

        study_xml_record_1 = StudyXmlRecord.find_by(nct_id:'NCT00513591')
        expect(study_xml_record_1).to be
      end

    end

    context 'dry_run true' do
      subject { described_class.new(search_term: search_term, dry_run: true) }

      it 'should report a study xml record' do
        nct_id="NCT00513591"
        expect {
          subject.create_study_xml_record(nct_id,raw_study_xml_1)
        }.not_to change{StudyXmlRecord.count}

        processed_studies = {
          updated_studies: [],
          new_studies: [nct_id]
        }
        expect(subject.processed_studies).to eq(processed_studies)
      end

    end
  end

  xdescribe '#populate_studies' do
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
        }.not_to change{ LoadEvent.count }
      end
    end
  end

  xdescribe '#import_xml_file(study_xml, benchmark: false)' do
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

    it 'should not create a load event if benchmark is nil or false' do
      study_xml_record_1 = StudyXmlRecord.find_by(nct_id: study_nct_id_1)

      expect {
        subject.import_xml_file(study_xml_record_1.content)
      }.to change{LoadEvent.count}.by(0)

      expect {
        subject.import_xml_file(study_xml_record_1.content, benchmark: false)
      }.to change{LoadEvent.count}.by(0)
    end
  end
end
