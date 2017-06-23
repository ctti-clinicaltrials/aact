class MeshTerm < ActiveRecord::Base
  def self.populate_from_file(file_name=ClinicalTrials::FileManager.default_mesh_terms)
    puts "about to populate table of mesh terms..."
    File.open(file_name).each_line{|line|
      line_array=line.split(' ')
      tree=line_array.first
      qualifier=tree.split('.').first
      desc=line_array[1]
      term=line.split(/\t/).last
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
