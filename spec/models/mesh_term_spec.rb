require 'rails_helper'

describe MeshTerm do
  it "should accurately load mesh terms from a file" do
    MeshTerm.populate_from_file(Rails.root.join('spec', 'support', 'flat_data', 'mesh_terms.txt'))
    expect(MeshTerm.count).to eq(82)
    term=MeshTerm.where('description = ?','D000071422').first
    expect(term.mesh_term).to eq('Inbreeding Depression')
  end

end

