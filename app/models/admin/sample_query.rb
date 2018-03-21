module Admin
  class SampleQuery
    #  we should probably create a 2-column table: Sample_Queries that defines check-type (ie. check performance) and the sql.
    #  then we can easily add query rows to the table as we find good examples.  For now, just return arrays containing sql strings.

    def self.check_performance
      [
      "SELECT s.nct_id,
        string_agg(DISTINCT CASE WHEN sp.lead_or_collaborator = 'collaborator'
                                THEN sp.name
                                 ELSE NULL
                           END, ' | ') AS Collaborators
         FROM studies s
         LEFT OUTER JOIN sponsors sp
         ON sp.nct_id = s.nct_id
         WHERE s.overall_status = 'Withdrawn'
         GROUP BY s.nct_id"
      ]
    end

  end
end
