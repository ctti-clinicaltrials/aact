json.study do
  json.merge! @study.attributes

  if @related_records == "true"
    json.brief_summary        @study.brief_summary.attributes
    json.design               @study.design.attributes
    json.detailed_description @study.detailed_description.attributes
    json.eligibility          @study.eligibility.attributes
    json.participant_flow     @study.participant_flow.attributes
    json.result_detail        @study.result_detail.attributes

#     json.facilities @study.facilities do |facility|
#       json.merge! facility.attributes
#     end
#
#     json.sponsors @study.sponsors do |sponsor|
#       json.merge! sponsor.attributes
#     end
#
#     json.pma_mappings @study.pma_mappings do |pma_mapping|
#       json.merge! pma_mapping.attributes
#     end
#
#     json.pma_records @study.pma_records do |pma_record|
#       json.merge! pma_record.attributes
#     end
#
#     json.expected_groups @study.expected_groups do |expected_group|
#       json.merge! expected_group.attributes
#     end
#
#     json.expected_outcomes @study.expected_outcomes do |expectes_outcome|
#       json.merge! expectes_outcome.attributes
#     end
#
#     json.groups @study.groups do |group|
#       json.merge! group.attributes
#     end
#
#     json.outcomes @study.outcomes do |outcome|
#       json.merge! outcome.attributes
#     end
#
#     json.baseline_measures @study.baseline_measures do |baseline_measure|
#       json.merge! baseline_measure.attributes
#     end
#
#     json.browse_conditions @study.browse_conditions do |browse_condition|
#       json.merge! browse_condition.attributes
#     end
#
#     json.browse_interventions @study.browse_interventions do |browse_intervention|
#       json.merge! browse_intervention.attributes
#     end
#
#     json.conditions @study.conditions do |condition|
#       json.merge! condition.attributes
#     end
#
#     json.drop_withdrawals @study.drop_withdrawals do |drop_withdrawal|
#       json.merge! drop_withdrawal.attributes
#     end
#
#     json.interventions @study.interventions do |intervention|
#       json.merge! intervention.attributes
#     end
#
#     json.keywords @study.keywords do |keyword|
#       json.merge! keyword.attributes
#     end
#
#     json.links @study.links do |link|
#       json.merge! link.attributes
#     end
#
#     json.milestones @study.milestones do |milestone|
#       json.merge! milestone.attributes
#     end
#
#     json.location_countries @study.location_countries do |location_country|
#       json.merge! location_country.attributes
#     end
#
#     json.outcome_measures @study.outcome_measures do |outcome_measure|
#       json.merge! outcome_measure.attributes
#     end
#
#     json.overall_officials @study.overall_officials do |overall_official|
#       json.merge! overall_official.attributes
#     end
#
#     json.oversight_authorities @study.oversight_authorities do |oversight_authority|
#       json.merge! oversight_authority.attributes
#     end
#
#     json.reported_events @study.reported_events do |reported_event|
#       json.merge! reported_event.attributes
#     end
#
#     json.responsible_parties @study.responsible_parties do |responsible_party|
#       json.merge! responsible_party.attributes
#     end
#
#     json.result_agreements @study.result_agreements do |result_agreement|
#       json.merge! result_agreement.attributes
#     end
#
#     json.result_contacts @study.result_contacts do |result_contact|
#       json.merge! result_contact.attributes
#     end
#
#     json.secondary_ids @study.secondary_ids do |secondary_id|
#       json.merge! secondary_id.attributes
#     end
#
#     json.references @study.references do |reference|
#       json.merge! reference.attributes
#     end
#
  end
end
