require 'rails_helper'

describe Util::TableExporter do
  describe '#run' do
    let(:table_exporter) { Util::TableExporter.new }
    let(:zipfile_name)   { table_exporter.zipfile_name }

    before do
      # this study has new line chars embedded in Outcomes.description.  Will verify they don't cause probs in flat files
      db = Util::DbManager.new
      db.remove_indexes_and_constraints
      Study.destroy_all
      record = StudyJsonRecord.create(nct_id: 'NCT05594173', content: JSON.parse(File.read('spec/support/json_data/NCT05594173.json')))
      record.create_or_update_study
      db.add_indexes
      db.add_constraints
      expect(Study.count).to eq(1)
    end

    after do
      File.delete(zipfile_name) if File.exist?(zipfile_name)
    end

    context 'export tables' do
      it 'should create all the temp files' do
        table_exporter = Util::TableExporter.new
        table_exporter.create_tempfiles('|')
        file_count = `ls public/static/tmp/export/*.txt | wc -l`.to_i
        expect(file_count).to eq(47)
      end

      it 'should create the correct data for outcomes' do
        table_exporter = Util::TableExporter.new
        File.open('public/static/tmp/export/outcomes.txt', 'wb+') do |file|
          table_exporter.export_table('outcomes', file, '|')
        end
        expect(File.read('public/static/tmp/export/outcomes.txt')).to eq(File.read('spec/support/outcomes.txt'))
      end
    end

    context 'all tables' do
      before do
        stub_request(:put, /https:\/\/aact-dev.nyc3.digitaloceanspaces.com\/.*/).to_return(:status => 200, :body => '', :headers => {})
      end

      it 'should have content in each csv' do
        table_exporter.run
        expect(FileRecord.count).to eq(1)
      end
    end
  end
end
