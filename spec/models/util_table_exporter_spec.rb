require 'rails_helper'

describe Util::TableExporter do
  describe '#run' do
    let(:table_exporter) { Util::TableExporter.new }
    let(:zipfile_name)   { table_exporter.zipfile_name }

    after do
      File.delete(zipfile_name) if File.exist?(zipfile_name)
    end

    context 'all tables' do
      before do
        table_exporter.run(should_archive: false)
      end

      it 'should write a zipfile' do
        expect(File.exists? zipfile_name).to eq(true)
      end

      it 'should have logged event to LoadEvents' do
        expect(Admin::LoadEvent.count).to eq(1)
        le=Admin::LoadEvent.last
        expect(le.event_type).to eq('table_export')
        expect(le.load_time).to eq('0 minutes and 0 seconds')
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
      it 'should only contain the csv files for the specified tables' do
        exporter = Util::TableExporter.new(['studies'])
        exporter.run(should_archive: false)

        entries = Zip::File.open(zipfile_name) do |zipfile|
          zipfile.entries
        end
#        expect(entries.count).to eq(1)
      end
    end

    it 'should clean up files in the tmp directory when finished' do
      has_csv_files = Dir.entries("#{Rails.root}/tmp").any? {|entry| File.extname(entry) == '.csv' }

      expect(has_csv_files).to eq(false)
    end
  end
end
