class PendingResult < StudyRelationship

  def self.create_all_from(opts)
    opts[:pending_results]=opts[:xml].xpath('//pending_results')
    return nil if opts[:pending_results].blank?
    submitted(opts) + returned(opts) + submission_canceled(opts)
  end

  def self.submitted(opts)
    opts[:pending_results].xpath('submitted').collect{|xml|
      val=xml.text
      create({
        :nct_id => opts[:nct_id],
        :event => 'submitted',
        :event_date_description => val,
        :event_date => val.try(:to_date),
      })
    }
  end

  def self.returned(opts)
    opts[:pending_results].xpath('returned').collect{|xml|
      val=xml.text
      create({
        :nct_id=>opts[:nct_id],
        :event=>'returned',
        :event_date_description=>val,
        :event_date=> val.try(:to_date),
      })
    }
  end

  def self.submission_canceled(opts)
    opts[:pending_results].xpath('submission_canceled').collect{|xml|
      val=xml.text
      create({
        :nct_id=>opts[:nct_id],
        :event=>'submission canceled',
        :event_date_description=>val,
        :event_date=> val.try(:to_date),
      })
    }
  end

end
