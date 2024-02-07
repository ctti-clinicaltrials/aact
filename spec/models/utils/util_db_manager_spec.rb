require 'rails_helper'

describe Util::DbManager do

  subject { described_class.new }

  context 'when loading the databases' do
    # it 'should add indexes and constraints' do
    #   event = Support::LoadEvent.create({:event_type=> 'test', :status => 'in prog'})
    #   mgr = Util::DbManager.new(event)
    #   mgr.add_indexes
    #   mgr.add_constraints
    #   study_indexes=mgr.indexes_for('studies')
    #   expect(study_indexes.size).to eq(15)

    #   mgr.remove_indexes_and_constraints
    #   study_indexes=mgr.indexes_for('studies')
    #   expect(study_indexes.size).to eq(1)  #  method should_keep_indexes? prevents the studies.nct_id from being removed.

    #   # checking that the number of indexes is correct
    #   mgr.add_indexes
    #   mgr.add_constraints
    #   study_indexes=mgr.indexes_for('studies')
    #   expect(study_indexes.size).to eq(15)

    #   # checking that the foreign keys are correct
    #   mgr.one_to_one_related_tables.each {|table_name|
    #     this_tables_indexes=mgr.indexes_for(table_name)
    #     nct_id_indexes = this_tables_indexes.select{ |i| i[:column_name]== 'nct_id' }
    #     sz=nct_id_indexes.size
    #     expect(nct_id_indexes.first[:is_unique]).to eq(true) if sz == 1
    #   }
    # end
  end
end
