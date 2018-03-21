require 'active_support/all'
module Admin
  class HealthCheck < Admin::AdminBase

    def check_performance
      Admin::SampleQuery.check_performance.each{|sql|
        query = "(analyze, format yaml) " + sql
        db_mgr=Util::DbManager.new
        results=db_mgr.con.explain(query)
        puts "======================"
        puts results.class
        puts results.inspect
        puts "======================"
      }
    end


  end
end
