class Milestone < ApplicationRecord
  
  def self.mapper(json)
    return unless json.results_section

    flow_periods = json.results_section.dig('ParticipantFlowModule', 'FlowPeriodList', 'FlowPeriod')
    flow_groups =  json.results_section.dig('ParticipantFlowModule')
    result_groups = create_and_group_results(flow_groups, 'Flow', 'Participant Flow')
    return unless flow_periods

    collection = []
    flow_periods.each do |period|

      flow_period = period['FlowPeriodTitle']
      flow_milestones = period.dig('FlowMilestoneList', 'FlowMilestone')
      next unless flow_milestones

      flow_milestones.each do |milestone|
        flow_achievements = milestone.dig('FlowAchievementList', 'FlowAchievement')
        next unless flow_achievements

        flow_achievements.each do |achievement|
          ctgov_group_code = achievement['FlowAchievementGroupId']
          collection << {
                          nct_id: nct_id,
                          result_group_id: result_groups[ctgov_group_code].try(:id),
                          ctgov_group_code: ctgov_group_code,
                          title: milestone['FlowMilestoneType'],
                          period: period['FlowPeriodTitle'],
                          description: achievement['FlowAchievementComment'],
                          count: achievement['FlowAchievementNumSubjects'],
                          milestone_description: milestone['FlowMilestoneComment'],
                          count_units: achievement['FlowAchievementNumUnits']
                        }
        end
      end
    end
    return if collection.empty?

    collection
  end

  def create_and_group_results(section, selector='Outcome', result_type='Outcome')
    groups = (section || {}).dig("#{selector}GroupList", "#{selector}Group") || []
    groups_data = StudyJsonRecord.result_groups(groups, selector, result_type, nct_id)
    result_groups = {}
    groups_data.each do |group|
      result_groups[group[:ctgov_group_code]] = ResultGroup.find_or_create_by(group)
    end

    return result_groups
  end

end