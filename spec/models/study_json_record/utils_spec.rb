require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
  
  hash = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))
  json_instance = StudyJsonRecord::ProcessorV2.new(hash)

  describe '#get_boolean' do
    it 'should return boolean value true if the input value is string "y"' do
      expect(json_instance.get_boolean("y")).to eq(true)
    end  
    it 'should return boolean value true if the input value is string "yes"' do
      expect(json_instance.get_boolean("yes")).to eq(true)
    end
    it 'should return boolean value true if the input value is string "true"' do
      expect(json_instance.get_boolean("true")).to eq(true)
    end
    it 'should return boolean value true if the input value is boolean value of true' do
      expect(json_instance.get_boolean(true)).to eq(true)
    end
    it 'should return boolean value false if the input value is string "n"' do
      expect(json_instance.get_boolean("n")).to eq(false)
    end  
    it 'should return boolean value false if the input value is string "no"' do
      expect(json_instance.get_boolean("no")).to eq(false)
    end
    it 'should return boolean value false if the input value is string "false"' do
      expect(json_instance.get_boolean("false")).to eq(false)
    end
    it 'should return boolean value false if the input value is boolean value of false' do
      expect(json_instance.get_boolean(false)).to eq(false)
    end
    it 'should return nil if the input value is empty' do
      expect(json_instance.get_boolean("")).to eq(nil)
    end
    it 'should return nil if the input value is nil' do
      expect(json_instance.get_boolean(nil)).to eq(nil)
    end
  end

  describe '#convert_to_date' do
    it 'should return end of year Date if only the year is given' do
      expect(json_instance.convert_to_date("2023")).to eq(Date.parse("Sun, 31 Dec 2023"))
    end  
    it 'should return end of month Date if only the year and month is given' do
      expect(json_instance.convert_to_date("2023-01")).to eq(Date.parse("Tue, 31 Jan 2023"))
    end
    it 'should return the year, month, and day format' do
      expect(json_instance.convert_to_date("2023-01-27")).to eq(Date.parse("Fri, 27 Jan 2023"))
    end
    it 'should return the year, month, day, hour and minute date-time format' do
      expect(json_instance.convert_to_date("2023-01-27T18:18")).to eq(DateTime.parse("Fri, 27 Jan 2023 18:18"))
    end
  end

  describe '#key_check' do
    it 'returns an empty hash when given nil' do
      expect(json_instance.key_check(nil)).to eq({})
    end
    it 'returns the same hash when given a non-nil hash' do
      hash = { key: 'value' }
      expect(json_instance.key_check(hash)).to eq(hash)
    end
    it 'returns an empty hash when given false' do
      expect(json_instance.key_check(false)).to eq({})
    end
    it 'returns an empty hash when given an undefined value' do
      # Simulating an undefined variable
      undefined_variable = nil
      undefined_variable = defined?(undefined_variable) ? undefined_variable : nil
      expect(json_instance.key_check(undefined_variable)).to eq({})
    end
  end

end
