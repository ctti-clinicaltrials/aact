class MeshTerm < ActiveRecord::Base
  def self.populate_from_file(file_name=ClinicalTrials::FileManager.default_mesh_terms)
    puts "about to populate table of mesh terms..."
    File.open(file_name).each_line{|line|
      line_array=line.split(' ')
      tree=line_array.first
      qualifier=tree.split('.').first
      desc=line_array[1]
      term=line.split(/\t/).last.strip
      if !qualifier.nil?
        new(:qualifier=>qualifier,
            :tree_number=>tree,
            :description=>desc,
            :mesh_term=>term,
           ).save!
      end
    }
  end

  def self.ids_possibly_related_to_condition(term)
    ids=[]
    searchable_term="%#{term}%"
    terms=MeshTerm.where('mesh_term like ?',searchable_term).pluck("mesh_term").uniq
    terms.each{|t| puts t}
    terms.each{|t|
      ids << BrowseCondition.where('mesh_term = ?',t).pluck(:nct_id).uniq if BrowseCondition.where('mesh_term = ?',t).count != 0
    }
    ids.flatten
  end
end
