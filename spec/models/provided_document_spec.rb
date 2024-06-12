require 'rails_helper'
import SchemaSwitcher

describe ProvidedDocument do
  

  NCT_ID = "NCT03064438"
  BASE_URL = "https://ClinicalTrials.gov/ProvidedDocs/"

  json_files = [
    # TODO: use full study data
    "provided_document.json"
  ]

  json_files.each do |json_file|
    context "When importing data from #{json_file}" do
      
      let(:content) { JSON.parse(File.read("spec/support/json_data/#{json_file}")) }

      # byebug
      before do
        @large_docs = content["documentSection"]["largeDocumentModule"]["largeDocs"]
        StudyJsonRecord.create(nct_id: NCT_ID, version: "2", content: content)
        StudyJsonRecord::Worker.new.process_study(NCT_ID)
      end

      describe 'ProvidedDocument' do
        it 'study should have expected provided_document info' do
          puts "expected_data: #{expected_data}"
          puts "import(ProvidedDocument): #{import(ProvidedDocument)}"
          expect(expected_data).to eq(import(ProvidedDocument))
        end
      end
      
    end
  end

  

  private

  def expected_data
    # byebug
    return unless @large_docs
    

    @large_docs.map do |document|
      {
        nct_id: NCT_ID,
        document_type: document["label"], 
        has_protocol: document["hasProtocol"],
        has_icf: document["hasIcf"], 
        has_sap: document["hasSap"], 
        document_date: Date.parse(document["date"]),
        url: "#{BASE_URL}#{NCT_ID[-2..-1]}/#{NCT_ID}/#{document["filename"]}"
      }
    end
  end

  def import(model)
    with_v2_schema { model.all.map { |x| x.attributes.except("id").symbolize_keys } }
  end
end
