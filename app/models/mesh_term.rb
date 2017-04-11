class MeshTerm < ActiveRecord::Base
  def self.populate_from_file(data=ClinicalTrials::FileManager.default_mesh_terms)
    puts "about to populate table of mesh terms..."
    data.each_line{|line|
      line_array=line.split(' ')
      tree=line_array.first
      qualifier=tree.split('.').first
      desc=line_array[1]
      term=line_array.last
      if !qualifier.nil?
        new(:qualifier=>qualifier,
            :tree_number=>tree,
            :description=>desc,
            :mesh_term=>term,
           ).save!
      end
    }
  end
end
