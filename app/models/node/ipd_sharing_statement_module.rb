module Node
  class IPDSharingStatementModule < Node::Base
    attr_accessor :ipd_sharing_time_frame, :ipd_sharing_access_criteria, :ipd_sharing_url,
                  :ipd_sharing, :ipd_sharing_description

    def process(root)
      root.study.ipd_time_frame = ipd_sharing_time_frame
      root.study.ipd_access_criteria = ipd_sharing_access_criteria
      root.study.ipd_url = ipd_sharing_url
      root.study.plan_to_share_ipd = ipd_sharing
      root.study.plan_to_share_ipd_description = ipd_sharing_description
    end
  end
end