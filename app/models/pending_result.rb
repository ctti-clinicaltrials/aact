class PendingResult < StudyRelationship

  def self.create_all_from(opts)
    pending_results=opts[:xml].xpath('//pending_results')
    return nil if pending_results.blank?
    opts[:pending_results]=pending_results.children
    collect_events(opts)
  end

  def self.collect_events(opts)
    opts[:pending_results].each{|event|
      if !event.blank?
        dt_val=event.text
        begin
          dt=dt_val.try(:to_date)
        rescue
          dt=nil
        end
        create({
          :nct_id => opts[:nct_id],
          :event => event.name,
          :event_date_description => dt_val,
          :event_date => dt,
        })
      end
    }
  end

end
