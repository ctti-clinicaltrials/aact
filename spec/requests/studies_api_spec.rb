require 'rails_helper'

describe AACT2::V1::StudiesAPI do
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

  let(:study) { Study.last }

  describe '[GET] study by nct_id' do
    subject { get "/api/v1/studies/#{requested_nct_id}" }

    context 'success' do
      let(:requested_nct_id) { study.nct_id }
      it 'should return the study' do
        is_expected.to eq(200)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
        returned_study_info = JSON.parse(response.body)
        expect(returned_study_info).to be_a Hash
        expect(returned_study_info).to have_key('study')
        expect(response.body).to include(StudySerializer.new(study).to_json)
      end

      context 'with related records' do
        before do
          study.with_related_records = true
        end
        subject { get "/api/v1/studies/#{requested_nct_id}?with_related_records=true" }

        context 'all one to one relationships' do

          it 'should return all related records for study' do
            is_expected.to eq(200)
            expect(response.body).to be
            expect(response.body).not_to eq('null')
            returned_study_info = JSON.parse(response.body)
            expect(returned_study_info).to be_a Hash
            expect(returned_study_info).to have_key('study')
            expect(response.body).to include(StudySerializer.new(study).to_json)
            
          end
        end

      end
    end

    context 'failure' do

      context 'study not found' do
        let(:requested_nct_id) { 'abc123' }
        it { is_expected.to eq(404) }
      end
    end
  end

  describe '[GET] all studies' do
    before do
      5.times do
        Study.create(xml: '')
      end
    end
    subject { get '/api/v1/studies' }

    context 'success' do
      it 'should return all studies' do
        is_expected.to eq(200)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
        studies_results = JSON.parse(response.body)
        expect(studies_results).to be_a Array
        expect(studies_results.length).to eq(6)
      end
    end

    context 'pagination' do
      let(:expected_per_page) { 2 }
      let(:expected_page) { 2 }
      subject {
        get('/api/v1/studies' ,
          {
            'per_page' => expected_per_page,
            'page' => expected_page
          }
        )
      }
      it 'should return paginated studies' do
        is_expected.to eq(200)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
        studies_results = JSON.parse(response.body)
        expect(studies_results).to be_a Array
        expect(studies_results.length).to eq(expected_per_page)
        expect(response.body).to include(
          ActiveModel::ArraySerializer.new(
            Study.all.to_a[expected_page,expected_per_page],
            each_serializer: StudySerializer
          ).to_json)
      end
    end
  end

  describe '[GET] study counts by year' do
    subject { get '/api/v1/studies/counts/by_year' }
    it 'should return a hash of years with counts of studies' do
      is_expected.to eq(200)
      study_start_year = Study.last.calculated_value.start_date.year.to_s
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      expect(JSON.parse(response.body)[study_start_year]).to eq(1)
    end
  end
end
