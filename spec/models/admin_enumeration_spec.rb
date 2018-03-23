require 'rails_helper'

describe Admin::Enumeration do
  it "saves a row using values in a hash & correctly gets column values for the last 2 entries for a table/column/value" do
    t_name='studies'
    c_name='overall_status'
    val='some value'
    [0,1,2,3].each {|num|
      hash={:table_name => t_name,
            :column_name => c_name,
            :column_value => val,
            :value_count => num,
            :value_percent => (num.to_f/6.to_f)  # denominator 6 = 0 + 1 + 2 + 3
           }
      described_class.create_from(hash)
    }
    result=described_class.get_last_two_for(t_name, c_name, val)
    expect(result.size).to eq(2)
    expect(result[:next_last].value_count).to eq(2)
    expect(result[:next_last].value_percent.round(2)).to eq(0.33)  #2/6
    expect(result[:last].value_count).to eq(3)
    expect(result[:last].value_percent.round(2)).to eq(0.50)  # 3/6
  end

end
