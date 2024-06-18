require 'rails_helper'

describe Document do
  it "should create an instance of Document", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Dataset Specification",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Study Protocol",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Annotated Case Report Form",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Clinical Study Report",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Informed Consent Form",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Statistical Analysis Plan",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      },
      {
        "nct_id" => "NCT000001",
        "document_id" => "109063",
        "document_type" => "Individual Participant Data Set",
        "url" => "https://www.clinicalstudydatarequest.com",
        "comment" => "For additional information about this study please refer to the GSK Clinical Study Register"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/document.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Document.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end
