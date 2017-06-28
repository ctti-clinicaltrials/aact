require 'rails_helper'

describe MeshTerm do
  before do
    MeshTerm.populate_from_file(Rails.root.join('spec', 'support', 'flat_data', 'mesh_terms.txt'))
  end

  it "should have accurately loaded mesh terms from a file." do
    expect(MeshTerm.count).to eq(82)
    term=MeshTerm.where('description = ?','D000071422').first
    expect(term.mesh_term).to eq('Inbreeding Depression')
  end

  it "Searching for studies about 'Depression' should find study about 'Inbreeding Depression'." do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(Study.all.size).to eq(1)
    ids=MeshTerm.ids_possibly_related_to_condition('Depression')
    expect(ids.size).to eq(1)
  end
end

