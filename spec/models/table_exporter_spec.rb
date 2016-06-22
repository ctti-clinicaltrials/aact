require 'rails_helper'

describe TableExporter do
  describe '#run' do
    let(:zipfile_name) { TableExporter::ZIPFILE_NAME }

    before do
      TableExporter.new.run
    end

    after do
      File.delete(zipfile_name) if File.exist?(zipfile_name)
    end


    context 'all tables' do
      it 'should write a zipfile' do
        expect(File.exists? zipfile_name).to eq(true)
      end

      it 'should have a csv for every table' do
        number_of_entries = Zip::File.open(zipfile_name) do |zipfile|
          zipfile.entries.count
        end

        expect(number_of_entries).to eq(45)
      end

      it 'should have content in each csv' do
        entries = Zip::File.open(zipfile_name) do |zipfile|
          zipfile.entries
        end

        entries.each do |entry|
          expect(entry.get_input_stream.read.length > 0).to eq(true)
        end
      end
    end

    context 'with specific tables' do

    end
  end
end
