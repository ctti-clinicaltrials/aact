require 'rails_helper'
describe Admin::SanityCheck do

  before do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.new.create_from(study).save!
    Admin::SanityCheck.new.save_row_counts
  end

  it 'should have one row for each study-related table' do
    expect(Admin::SanityCheck.count).to eq(42)
  end

  it 'correctly detects when enumeration changed by > 10%' do
    #  Create a set of enumerations for a specific table/column/value
    allow_any_instance_of(Admin::Enumeration).to receive(:is_day_to_create_enums?).and_return( true )
    Admin::Enumeration.destroy_all
    t_name='studies'
    c_name='overall_status'
    val='some value'
    [1,2].each {|num|
      hash={:table_name => t_name,
            :column_name => c_name,
            :column_value => val,
            :value_count => num,
            :value_percent => ((num*100)/8).to_f
           }
      Admin::Enumeration.new.create_from(hash)
    }
    Admin::Enumeration.all.each{|x| puts x.inspect}

    described_class.destroy_all
    described_class.new.check_enumerations
    cks=described_class.all
    expect(cks.size).to eq(1)
    ck=cks.first
    expect(ck.table_name).to eq(t_name)
    expect(ck.column_name).to eq(c_name)
    expect(ck.check_type).to eq('enumeration')
    expect(ck.most_current).to eq(true)
    expect(ck.description).to eq("enumeration changed by more than 10%: 12.0% -> 25.0%")

    # Change the 2nd Enumeration's percent_value so it's within 10% of the previous and reun the sanity check.
    # This should not cause a SanityCheck to get created since it's within a sane range.
    reset_enum=Admin::Enumeration.where('value_count=?',2).first
    reset_enum.value_percent=21
    reset_enum.save!
    described_class.destroy_all
    described_class.new.check_enumerations
    cks=described_class.all
    expect(cks.size).to eq(0)
  end

  it 'should have row count 1 for each table that has 1-to-1 relationship with studies table' do
    Util::Updater.single_study_tables.each{|table_name|
       rows=Admin::SanityCheck.where('table_name=?',table_name)
       expect(rows.size).to eq(1)
       row=rows.first
       expect(row.row_count).to eq(1)
    }
  end

  it "correctly detects duplicates in tables with one-to-one relationship to study" do
    nct_id='NCT00023673'
    BriefSummary.new({:nct_id=>nct_id,:description=>"duplicate for #{nct_id}"}).save!
    Admin::SanityCheck.new.check_for_duplicates
    sc=Admin::SanityCheck.where('nct_id=? and table_name=?',nct_id,'brief_summaries duplicate')
    expect(sc.size).to eq(1)
  end

  it "correctly detects orphans" do
    nct_id='NCT01065844'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(2)
    study.outcomes.each{|x|x.destroy}
    outcomes=Outcome.where('nct_id=?',nct_id)
    expect(outcomes.size).to eq(0)
    sc=Admin::SanityCheck.new
    sc.check_for_orphans
    sc=Admin::SanityCheck.where('nct_id=?',nct_id)
    expect(sc.size).to eq(1)
    expect(sc.first.table_name).to eq('outcome_measurements')
    expect(sc.first.description).to eq('Orphaned from outcomes')
  end

end
