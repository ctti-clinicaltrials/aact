require 'active_support/all'
module Admin
  class HealthCheckQuery < Admin::AdminBase

    def populate
      con=Util::DbManager.new.con
      result=con.execute(query1)
      puts result.to_a
      #  maybe parse for 'Seq Scan' which indicates a slow query
    end

    def query1
      "EXPLAIN (ANALYZE) SELECT s.nct_id,
             (SELECT string_agg(DISTINCT sp.name, ' | ')
                FROM sponsors sp
               WHERE sp.nct_id = s.nct_id AND sp.lead_or_collaborator = 'collaborator') AS Collaborators
         FROM studies s
        WHERE s.overall_status = 'Withdrawn'
        ORDER BY s.nct_id"
    end

  end
end
