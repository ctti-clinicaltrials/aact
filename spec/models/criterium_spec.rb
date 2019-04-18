require 'rails_helper'

RSpec.describe Criterium, type: :model do
  context 'when criteria provided' do

    it 'should handle when inc/excl headers are unusual' do
      described_class.destroy_all
      nct_id='NCT03424005'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)
      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(inclusion.size).to eq(21)
      expect(exclusion.size).to eq(21)
    end

    it 'should handle studies that only have inclusion criteria' do
      described_class.destroy_all
      sample1_name = "Women of childbearing potential must have a negative serum pregnancy test within 2 weeks prior to registration; patients that are pregnant or breast feeding are excluded; a female of childbearing potential is any woman, regardless of sexual orientation or whether they have undergone tubal ligation, who meets the following criteria:"
      nct_id= 'NCT02465060'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)
      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(0)
      expect(inclusion.size).to eq(82)
      # should strip off leading ' - '
      sample = described_class.where('order_number=1 and parent_id is null').first
      expect(sample.name).to eq(sample1_name)
      # should link children criteria to appropriate parent
      children = described_class.where('parent_id = ?', sample.id)
      expect(children.size).to eq(2)
      # should link children criteria to another child criterium where appropriate
      parent_sample = described_class.where('name=?',"Patients must have an electrocardiogram (ECG) within 8 weeks prior to registration to screening step and must meet the following cardiac criteria:").first
      child_sample = described_class.where('name=?',"Resting corrected QT interval (QTc) =< 480 msec").first
      expect(child_sample.criterium_type).to eq('inclusion')
      grandchild_sample = described_class.where('name=?',"NOTE: If the first recorded QTc exceeds 480 msec, two additional, consecutive ECGs are required and must result in a mean resting QTc =< 480 msec; it is recommended that there are 10-minute (+/- 5 minutes) breaks between the ECGs").first
      expect(child_sample.parent_id).to eq(parent_sample.id)
      expect(grandchild_sample.parent_id).to eq(child_sample.id)
    end

    it 'should parse inclusion section and save each one' do
      described_class.destroy_all
      nct_id='NCT03599518'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(23)
      expect(inclusion.size).to eq(12)
      incl_with_parents=inclusion.select{|x| !x.parent_id.nil?}
      excl_with_parents=exclusion.select{|x| !x.parent_id.nil?}
      expect(incl_with_parents.size).to eq(2)
      expect(excl_with_parents.size).to eq(8)
      sample=inclusion.first
      expect(sample.name).to eq('Has histologically or cytologically documented adenocarcinoma NSCLC')
      expect(sample.downcase_name).to eq('has histologically or cytologically documented adenocarcinoma nsclc')
      expect(sample.order_number).to eq(1)
      sample=described_class.where('criterium_type=? and order_number=3','inclusion').first
      expect(sample.name).to eq('Has acquired resistance to EGFR tyrosine kinase inhibitor (TKI) according to the Jackman criteria (PMID: 19949011):')
      expect(sample.parent_id).to be(nil)
    end

    xit 'should handle studies that specify diff types of criteria' do
      'NCT01220531 Transplant Inclusion:'
      'NCT02260193  Key Inclusion & Key Exclusion Criteria'
    end

    it 'should handle studies with criteria all on one line' do
      described_class.destroy_all
      nct_id='NCT03840122'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      expect(exclusion.size).to eq(4)
      expect(inclusion.size).to eq(4)

      sample = inclusion.select{|x| x.order_number == 1}.first
      expect(sample.name).to eq('Patient is over the age of 21')
      sample = exclusion.select{|x| x.order_number == 1}.first
      expect(sample.name).to eq('Patient is under the age of 21')

      'NCT03720470 has both inclusion & exclusion all on one line'
    end

    it 'should handle studies with criteria specifies neither inclusion or exclusion' do
      "NCT02481830 doesn't specify inclusion or exclusion"
      described_class.destroy_all
      nct_id='NCT02481830'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts={xml: xml, nct_id: nct_id}
      described_class.create_all_from(opts)

      inclusion = described_class.where(criterium_type: 'inclusion')
      exclusion = described_class.where(criterium_type: 'exclusion')
      other     = described_class.where(criterium_type: 'other')
      expect(inclusion.size).to eq(4)
      expect(exclusion.size).to eq(3)
      expect(other.size).to eq(1)
      sample = exclusion.select{|x| x.order_number == 3 }.first
      expect(sample.name).to eq("Inadequate hematologic or hepatic function")

      "For more information regarding BMS clinical trial participation, please visit www.BMSStudyConnect.com
      Inclusion Criteria:
      - Histologically or cytologically confirmed small cell lung cancer (SCLC)
      - Subjects with either limited or extensive disease stage at the initial diagnosis
      - Must have recurrence or progression after platinum-based first-line chemotherapy or chemoradiation therapy for the treatment of limited or extensive disease stage SCLC
      - Eastern Cooperative Oncology Group (ECOG) performance status 0 or 1
      Exclusion Criteria:
      - Untreated or symptomatic central nervous system (CNS) metastases
      - Prior therapy with anti-PD-1, anti-PDL1, anti-PD-L2, anti-CD137, or anti-CTLA-4 antibody
      - Inadequate hematologic or hepatic function"
    end
  end

end
