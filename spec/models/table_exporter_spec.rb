require 'rails_helper'

describe TableExporter do
  describe '#run' do
    after do
      File.delete(TableExporter::ZIPFILE_NAME) if File.exist?(TableExporter::ZIPFILE_NAME)
    end

    context 'all tables' do
      it 'should write a zipfile' do
        TableExporter.new.run

        expect(File.exists? TableExporter::ZIPFILE_NAME).to eq(true)
      end
    end

    context 'with specific tables' do

    end
  end
end
