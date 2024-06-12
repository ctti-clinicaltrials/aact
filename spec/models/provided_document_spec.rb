require "rails_helper"

describe ProvidedDocument do
  include SchemaSwitcher

  NCT_ID = "NCT03064438"
  json_files = ["provided_document.json"]

  json_files.each do |json_file|
    context "When importing data from #{json_file}" do
      let(:content) { JSON.parse(File.read("spec/support/json_data/#{json_file}")) }
      let(:large_docs) { content["documentSection"]["largeDocumentModule"]["largeDocs"] }
      let(:expected_data) { get_expected_data(large_docs) }

      before do
        StudyJsonRecord.create(nct_id: NCT_ID, version: "2", content: content)
        StudyJsonRecord::Worker.new.process_study(NCT_ID)
      end

      describe "Data Import and Mapping" do
        subject { import(ProvidedDocument) }

        it "correctly maps data from JSON to model attributes" do
          expect(subject).to eq(expected_data)
        end
      end
    end
  end

  context "Document URLs" do
    let(:nct_id) { NCT_ID }
    let(:filename) { "SAP_001.pdf" }
    let(:expected_url) { "https://ClinicalTrials.gov/ProvidedDocs/38/NCT03064438/SAP_001.pdf" }

    describe ".build_document_url" do
      subject { ProvidedDocument.build_document_url(nct_id, filename) }

      it "constructs the document URL correctly" do
        expect(subject).to eq(expected_url)
      end
    end

    # TODO: add test to make sure that the URL is accessible
  end

  private

  def get_expected_data(documents)
    return [] unless documents
    documents.map do |document|
      {
        nct_id: NCT_ID,
        document_type: document["label"],
        has_protocol: document["hasProtocol"],
        has_icf: document["hasIcf"],
        has_sap: document["hasSap"],
        document_date: Date.parse(document["date"]),
        url: ProvidedDocument.build_document_url(NCT_ID, document["filename"])
      }
    end
  end

  def import(model)
    with_v2_schema { model.all.map { |x| x.attributes.except("id").symbolize_keys } }
  end
end