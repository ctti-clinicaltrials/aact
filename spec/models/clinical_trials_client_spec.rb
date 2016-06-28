require 'rails_helper'

describe ClinicalTrials::Client do
  let(:client) { described_class.new(search_term: 'lacrosse') }
  let(:studies) { [File.read(Rails.root.join('spec',
                                             'support',
                                             'xml_data',
                                             'example_study.xml'))] }
  let(:study) { studies.first }
  let(:study_id) { 'NCT00002475' }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      client = described_class.new(
        search_term: 'pancreatic cancer vaccine'
      )

      expect(client.url).to eq('https://clinicaltrials.gov/search?term=pancreatic+cancer+vaccine&resultsxml=true')
    end
  end

  describe '#create_study_xml_record' do
    before do
      client.create_study_xml_record(study)
    end

    context 'fresh db' do
      it 'should create a study xml record' do
        expect(StudyXmlRecord.last.nct_id).to eq(study_id)
      end
    end

    context 'with duplicate in db' do
      let(:xml_record) { StudyXmlRecord.last }

      context 'study has not changed' do
        it 'should not create a new xml record or modify the current one' do
          updated_at = xml_record.updated_at
          doc = Nokogiri::XML(study)
          doc.xpath('//clinical_study')
             .xpath('//required_header')
             .xpath('//download_date').children.first.content = 'New date'
          updated_doc_with_only_download_date = doc.to_xml

          client.create_study_xml_record(updated_doc_with_only_download_date)

          expect(StudyXmlRecord.count).to eq(1)
          expect(xml_record.updated_at).to eq(updated_at)
        end
      end

      context 'study has changed' do
        it 'should update the study' do
          updated_at = xml_record.updated_at
          doc = Nokogiri::XML(study)
          doc.xpath('//clinical_study').xpath('//official_title').children.first.content = 'New title'
          updated_doc = doc.to_xml

          client.create_study_xml_record(updated_doc)

          expect(StudyXmlRecord.last.updated_at).not_to eq(updated_at)
        end
      end

    end
  end

  describe '#import_xml_file' do

    context 'success' do
      before do
        client.import_xml_file(study)
      end

      it 'should create study from the xml_record' do
        expect(Study.count).to eq(1)
        expect(Study.last.nct_id).to eq(study_id)
      end

    end

    context 'failure' do
      context 'duplicate study' do
        let!(:xml_record) { StudyXmlRecord.create(content: study, nct_id: client.send(:extract_nct_id_from_study, study)) }

        it 'should not create new study' do
          client.import_xml_file(study)
          client.import_xml_file(study)

          expect(Study.all.count).to eq(1)
          expect(Study.last.updated_at).to eq(Study.last.created_at)
        end

        context 'study has changed' do
          before do
            client.import_xml_file(study)
            doc = Nokogiri::XML(study)
            @new_title = 'Testing File For Import Differences'
            doc.xpath('//clinical_study').xpath('//official_title').children.first.content = @new_title
            doc.xpath('//clinical_study').xpath('lastchanged_date').children.first.content = 'Jan 1, 2016'
            @updated_study = doc.to_xml
            client.import_xml_file(@updated_study)
          end

          it 'should update study' do
            expect(Study.all.count).to eq(1)
            Study.last.official_title
            expect(Study.last.last_changed_date.to_s).to eq('2016-01-01')
            expect(Study.last.official_title).to eq(@new_title)
            expect(Study.last.updated_at).not_to eq(Study.last.created_at)
          end

          it 'should update the study xml record' do
            expect(StudyXmlRecord.count).to eq(1)

            updated_content = StudyXmlRecord.last.content
            imported_content = Nokogiri::XML(@updated_study).xpath("//clinical_study").to_xml
            expect(updated_content.chomp).to eq(imported_content)
          end
        end

      end
    end

  end

end
