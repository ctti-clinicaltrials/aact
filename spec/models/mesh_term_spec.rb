require 'rails_helper'

describe MeshTerm do
  before do
    MeshTerm.populate_from_file(Rails.root.join('spec', 'support', 'flat_data', 'mesh_terms.txt'))

    ids=['NCT02586688','NCT03228394','NCT00023673']  # 2 studies about depression; one not
    ids.each{|id|
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{id}.xml"))
      Study.new({xml: xml, nct_id: id}).create
    }
    CalculatedValue.populate  # create downcase version of mesh_terms to make matching easier
  end

  it "should have accurately loaded mesh terms from a file." do
    expect(MeshTerm.count).to eq(152)
    term=MeshTerm.where('tree_number = ?','G05.410').first
    expect(term.qualifier).to eq('G05')
    expect(term.mesh_term).to eq('Inbreeding Depression')
    expect(term.downcase_mesh_term).to eq('inbreeding depression')
  end

  it "finds studies about 'Depression' - no matter the case." do
    expect(Study.count).to eq(3)
    ids=MeshTerm.ids_related_to(['Depression'])
    expect(ids.size).to eq(2)
    ids=MeshTerm.ids_related_to(['depression'])
    expect(ids.size).to eq(2)
    ids=MeshTerm.ids_related_to(['DEPRESSION'])
    expect(ids.size).to eq(2)
  end

end

