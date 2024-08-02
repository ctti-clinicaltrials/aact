require 'rails_helper'

describe Util::TableExporter do

  describe '#run' do
    let!(:table_exporter) { Util::TableExporter.new }
    let(:zipfile_name)   { table_exporter.zipfile_name }

    before do
      # this study has new line chars embedded in Outcomes.description.  Will verify they don't cause probs in flat files
      record = StudyJsonRecord.create(nct_id: 'NCT05594173', version: 2, content: JSON.parse(File.read('spec/support/json_data/NCT05594173.json')))
      worker = StudyJsonRecord::Worker.new
      worker.process_study('NCT05594173')
      expect(Study.count).to eq(1)
    end

    context 'export tables' do
      it 'should create all the temp files' do
        table_exporter.create_tempfiles('|')
        file_count = Dir.glob('public/static/tmp/export/*.txt').count
        expect(file_count).to eq(StudyRelationship.loadable_tables.count)
      end

      it 'should create the correct data for outcomes' do
        File.open('public/static/tmp/export/outcomes.txt', 'wb+') do |file|
          table_exporter.export_table('outcomes', file, '|')
        end
        result_file = ''
        File.open('public/static/tmp/export/outcomes.txt', 'r') do |input_file|
          output_lines = ''
          # Iterate through each line in the input file and remove the first column
          input_file.each_line do |line|
            columns = line.chomp.split('|')
            columns.shift
            modified_line = columns.join('|')
            output_lines << modified_line + "\n"
          end
          result_file = output_lines
        end
        expect(result_file).to eq(File.read('spec/support/outcomes.txt'))
      end
    end

    context 'all tables' do
      before do
        stub_request(:put, /https:\/\/aact-dev.nyc3.digitaloceanspaces.com\/.*/).to_return(:status => 200, :body => '', :headers => {})
      end

      it 'creates a file record after running the exporter' do
        table_exporter.run 
        expect(FileRecord.count).to eq(1)
        # run takes care of removing temp files
        file_count = Dir.glob('public/static/tmp/export/*.txt').count
        expect(file_count).to eq(0)
      end
    end
  end
end
