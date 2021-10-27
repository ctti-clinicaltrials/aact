class Verifier < ActiveRecord::Base
  def verify
    study_statistics = ClinicalTrialsApi.study_statistics.dig('StudyStatistics', "ElmtDefs", "Study")
    return unless study_statistics

    update(differences: [])
    all_locations.each do |key,value|
      found = diff_hash(study_statistics, key, value)
      differences << found unless found.blank?
    end

    self.save
  end

  def same?(int1,int2)
    int1.to_i == int2.to_i
    
  end

  def diff_hash(hash, selector, location)
    selector.split('|').each do |selector_part|
      hash = hash.dig(selector_part)
    end
    section = selector.last 

    return unless hash

    all_instances = hash.dig("nInstances")
    uniq_instances = hash.dig("nUniqueValues")
    
    all_counts, uniq_counts = get_counts(location)

      unless same?(all_counts, all_instances) && same?(uniq_counts, uniq_instances)
        return {
                    source: selector,
                    destination: location,
                    source_instances: all_instances,
                    destination_instances: all_counts,
                    source_unique_values: uniq_instances,
                    destination_unique_values: uniq_counts,
              }
            else return false
      end

  # {
  #   source: "LocationInAPI",
  #   destination: "table_name#column_name",
  #   source_instances: 0,
  #   destination_instances: 0,
  #   source_unique_values: 0,
  #   destination_unique_values: 0
  # }
  end

  def all_locations
    id_module="ProtocolSection|IdentificationModule"
    {
      "#{id_module}|NCTId" => "studies#nct_id",
      "#{id_module}|NCTIdAliasList|NCTIdAlias" => "id_information#id_value",
      ""
    }
  end

  def get_counts(location)
    return unless location && location.kind_of?(String)

    # example "studies#nct_id"
    array = location.split('#')
    con = ActiveRecord::Base.connection
    
    all_counts = con.execute("select count(#{array[1]}) from #{array[0]}")
    all_counts = all_counts.getvalue(0,0) if all_counts.ntuples == 1

    uniq_counts = con.execute("select count(distinct #{array[1]}) from #{array[0]}")
    uniq_counts = uniq_counts.getvalue(0,0) if uniq_counts.ntuples == 1
    
    return all_counts, uniq_counts
  end
  # def study_counts(hash)


  # end

  
end
