require 'rails_helper'
# studies to test:
#NCT01090362 - an ongoing registry with cohorts. Data may change (e.g., facilities, recruitment status). Currently no results.
#NCT01431326 - an ongoing observational study, no cohorts, has biospecimen info. Data may change. Lots of interventions and conditions, many secondary ids. Currently no results.
#NCT01076361 - completed registry study with results. Reports some results by number of patients and some by number of implanted leads.

#Interventional studies:
#NCT00734539 - completed phase 3 trial with results. Would not expect changes to study data.
#NCT00650091 - completed phase 3 trial with results. An example of a study with some discontinued study arms, and #events reported for AEs/SAEs.
#NCT00799903 - completed phase 3 trial with no reported results. An example of a study with 'delayed results' date.
#NCT02654730 - phase 2 / phase 3 ongoing study. Complicated intervention/arm structure. An example of a study with responses about plans to share individual patient data.
#NCT01841593 - phase 1 crossover study with results. Participant flow reported by several periods. Example of how different groups are used to report different components of the summary results.
#NCT01841593 - phase 1 crossover study with results. Participant flow reported by different periods. Example of how different groups are used to report different components of the analysis. Reporting of results for outcome measures includes statistical analysis data elements.
#NCT01174550 - Phase N/A trial with results. Includes data elements regarding sharing individual patient data. Results include example of reporting outcomes over time.
#NCT00660179

describe Study do
  subject { Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                          'support',
                                                          'xml_data',
                                                          'example_study.xml'))), nct_id: 'NCT00002475'}).create }

  describe 'associations' do
    it { should have_one(:brief_summary).dependent(:delete) }
    it { should have_one(:design).dependent(:delete) }
    it { should have_one(:detailed_description).dependent(:delete) }
    it { should have_one(:eligibility).dependent(:delete) }
    it { should have_one(:participant_flow).dependent(:delete) }
    it { should have_one(:calculated_value).dependent(:delete) }
    it { should have_one(:study_xml_record) }
    it { should have_many(:baseline_measurements).dependent(:delete_all) }
    it { should have_many(:baseline_counts).dependent(:delete_all) }
    it { should have_many(:design_groups).dependent(:delete_all) }
    it { should have_many(:design_outcomes).dependent(:delete_all) }
    it { should have_many(:id_information).dependent(:delete_all) }
    it { should have_many(:result_groups).dependent(:delete_all) }
    it { should have_many(:browse_conditions).dependent(:delete_all) }
    it { should have_many(:browse_interventions).dependent(:delete_all) }
    it { should have_many(:central_contacts).dependent(:delete_all) }
    it { should have_many(:conditions).dependent(:delete_all) }
    it { should have_many(:countries).dependent(:delete_all) }
    it { should have_many(:drop_withdrawals).dependent(:delete_all) }
    it { should have_many(:facilities).dependent(:delete_all) }
    it { should have_many(:interventions).dependent(:delete_all) }
    it { should have_many(:keywords).dependent(:delete_all) }
    it { should have_many(:links).dependent(:delete_all) }
    it { should have_many(:milestones).dependent(:delete_all) }
    it { should have_many(:outcomes).dependent(:delete_all) }
    it { should have_many(:outcome_analyses).dependent(:delete_all) }
    it { should have_many(:outcome_measurements).dependent(:delete_all) }
    it { should have_many(:overall_officials).dependent(:delete_all) }
    it { should have_many(:responsible_parties).dependent(:delete_all) }
    it { should have_many(:result_agreements).dependent(:delete_all) }
    it { should have_many(:result_contacts).dependent(:delete_all) }
    it { should have_many(:sponsors).dependent(:delete_all) }
    it { should have_many(:references).dependent(:delete_all) }
  end

  describe '.create_calculated_values' do
    before do
      expect(subject).to be_persisted
      CalculatedValue.new.create_from(subject).save!
    end

    it 'should have created a calculated value record for each study' do
      expect(CalculatedValue.count).to eq(1)
    end
  end

  describe 'with_related_records' do
    it { is_expected.to respond_to 'with_related_records'}
    it { is_expected.to respond_to 'with_related_records=' }

    it 'should allow the with_related_records attribute to be set' do
      expect(subject.with_related_records).not_to be true
      subject.with_related_records = true
      expect(subject.with_related_records).to be true
    end
  end
end
