require 'rails_helper'

describe Util::TableExporter do
  describe '#run' do
    let(:table_exporter) { Util::TableExporter.new }
    let(:zipfile_name)   { table_exporter.zipfile_name }

    before do
      # this study has new line chars embedded in Outcomes.description.  Will verify they don't cause probs in flat files
      nct_id='NCT03191552'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create
    end

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
      end

      it 'should have content in each csv' do
        entries = Zip::File.open(zipfile_name) do |zipfile|
          zipfile.entries
        end

        entries.each do |entry|
          # some Outcomes have descriptions with embedded newline chars. Make sure they're escaped
          if entry.name == 'outcomes.txt'
            content=entry.get_input_stream.read
            # every row should begin with the id (an integer)
            rows=content.split("\n")
            rows.each{|row|
              attribs=row.split("|")
              expect(attribs.first.is_a? Integer).to eq(true) if attribs.first != 'id'
            }
          end
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
