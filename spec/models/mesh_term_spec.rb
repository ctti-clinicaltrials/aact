require 'rails_helper'

describe MeshTerm do
  before do
    MeshTerm.populate_from_file(Rails.root.join('spec', 'support', 'flat_data', 'mesh_terms.txt'))

    ids=['NCT02586688','NCT00023673','NCT00081588','NCT00277524','NCT00482794','NCT00513591']
    ids.each{|id|
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{id}.xml"))
      Study.new({xml: xml, nct_id: id}).create
    }
    CalculatedValue.populate  # create downcase version of mesh_terms to make matching easier
  end

  it "should have accurately loaded mesh terms from a file." do
    expect(MeshTerm.count).to eq(152)
    term=MeshTerm.where('description = ?','D000071422').first
    expect(term.mesh_term).to eq('Inbreeding Depression')
    expect(term.downcase_mesh_term).to eq('inbreeding depression')
  end

  it "finds study about 'Inbreeding Depression' when searching for studies about 'Depression' - no matter the case." do
    expect(Study.count).to eq(6)
    ids=MeshTerm.ids_related_to(['Depression'])
    expect(ids.size).to eq(3)
    ids=MeshTerm.ids_related_to(['depression'])
    expect(ids.size).to eq(3)
    ids=MeshTerm.ids_related_to(['DEPRESSION'])
    expect(ids.size).to eq(3)
  end

end

