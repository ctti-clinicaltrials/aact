class StudyJsonRecord < ActiveRecord::Base
  def collect_attributes
    deep_info = content['Study']['ProtocolSection']['StatusModule']
    {
      :start_month_year              => deep_info['StartDateStruct']['StartDate'],
      :verification_month_year       => deep_info['StatusVerifiedDate'],
      :completion_month_year         => deep_info['CompletionDateStruct']['CompletionDate'],
      :primary_completion_month_year => deep_info['PrimaryCompletionDateStruct']['PrimaryCompletionDate'],

      :start_date                    => convert_date(deep_info['StartDateStruct']['StartDate']),
      :verification_date             => convert_date(deep_info['StatusVerifiedDate']),
      :completion_date               => convert_date(deep_info['CompletionDateStruct']['CompletionDate']),
      :primary_completion_date       => convert_date(deep_info['PrimaryCompletionDateStruct']['PrimaryCompletionDate']),

      :study_first_submitted_qc_date        => get(deep_info['StudyFirstSubmitQCDate']).try(:to_date),
      :study_first_posted_date              => get(deep_info['StudyFirstPostDateStruct']['StudyFirstPostDate']).try(:to_date),
      :results_first_submitted_qc_date      => get('results_first_submitted_qc').try(:to_date),
      :results_first_posted_date            => get('results_first_posted').try(:to_date),
      :disposition_first_submitted_qc_date  => get('disposition_first_submitted_qc').try(:to_date),
      :disposition_first_posted_date        => get('disposition_first_posted').try(:to_date),
      :last_update_submitted_qc_date        => get(deep_info['LastUpdateSubmitDate']).try(:to_date),
      :last_update_posted_date              => get(deep_info['LastUpdatePostDateStruct']['LastUpdatePostDate']).try(:to_date),

      # the previous have been replaced with:
      :study_first_submitted_date       => get_date(get('study_first_submitted')),
      :results_first_submitted_date     => get_date(get('results_first_submitted')),
      :disposition_first_submitted_date => get_date(get('disposition_first_submitted')),
      :last_update_submitted_date       => get_date(get('last_update_submitted')),

      :nlm_download_date_description  => xml.xpath('//download_date').text,
      :acronym                        => get('acronym'),
      :baseline_population            => xml.xpath('//baseline/population').try(:text),
      :number_of_arms                 => get('number_of_arms'),
      :number_of_groups               => get('number_of_groups'),
      :source                         => get('source'),
      :brief_title                    => get('brief_title') ,
      :official_title                 => get('official_title'),
      :overall_status                 => get('overall_status'),
      :last_known_status              => get('last_known_status'),
      :phase                          => get('phase'),
      :target_duration                => get('target_duration'),
      :enrollment                     => get('enrollment'),
      :biospec_description            => get_text('biospec_descr'),

      :start_date_type                     => get_type('start_date'),
      :primary_completion_date_type        => get_type('primary_completion_date'),
      :completion_date_type                => get_type('completion_date'),
      :study_first_posted_date_type        => get_type('study_first_posted'),
      :results_first_posted_date_type      => get_type('results_first_posted'),
      :disposition_first_posted_date_type  => get_type('disposition_first_posted'),
      :last_update_posted_date_type        => get_type('last_update_posted'),
      :enrollment_type                     => get_type('enrollment'),

      :study_type                        => get('study_type'),
      :biospec_retention                 => get('biospec_retention'),
      :limitations_and_caveats           => xml.xpath('//limitations_and_caveats').text,
      :is_fda_regulated_drug             => get_boolean('//is_fda_regulated_drug'),
      :is_fda_regulated_device           => get_boolean('//is_fda_regulated_device'),
      :is_unapproved_device              => get_boolean('//is_unapproved_device'),
      :is_ppsd                           => get_boolean('//is_ppsd'),
      :is_us_export                      => get_boolean('//is_us_export'),
      :ipd_time_frame                    => get('patient_data/ipd_time_frame'),
      :ipd_access_criteria               => get('patient_data/ipd_access_criteria'),
      :ipd_url                           => get('patient_data/ipd_url'),
      :plan_to_share_ipd                 => get('patient_data/sharing_ipd'),
      :plan_to_share_ipd_description     => get('patient_data/ipd_description'),
      :has_expanded_access               => get_boolean('//has_expanded_access'),
      :expanded_access_type_individual   => get_boolean('//expanded_access_info/expanded_access_type_individual'),
      :expanded_access_type_intermediate => get_boolean('//expanded_access_info/expanded_access_type_intermediate'),
      :expanded_access_type_treatment    => get_boolean('//expanded_access_info/expanded_access_type_treatment'),
      :has_dmc                           => get_boolean('//has_dmc'),
      :why_stopped                       => get('why_stopped')
    }
  end

  def self.true_attrib(big_hash=study_structure)
    big_hash = JSON.parse(big_hash)
    content = big_hash['StudyStructure']['ElmtDefs']
    protocol = content['Study']['ProtocolSection']
    status = protocol['StatusModule']
    ident = protocol['IdentificationModule']
    design = protocol['DesignModule']
    oversight= protocol['OversightModule']
    ipd_sharing = protocol['IPDSharingStatementModule']
    results = content['Study']['ResultsSection']
    baseline = results['BaselineCharacteristicsModule']
    { 
      nct_id: nct_id,
      nlm_download_date_description: nil,
      study_first_submitted_date: status['StudyFirstSubmitDate'],
      results_first_submitted_date: status['ResultsFirstSubmitDate'],
      disposition_first_submitted_date: status['DispFirstSubmitDate'],
      last_update_submitted_date: status['LastUpdateSubmitDate'],
      study_first_submitted_qc_date: status['StudyFirstSubmitQCDate'],
      study_first_posted_date: status['StudyFirstPostDateStruct']['StudyFirstPostDate'],
      study_first_posted_date_type: status['StudyFirstPostDateStruct']['StudyFirstPostDateType'],
      results_first_submitted_qc_date: status['ResultsFirstSubmitQCDate'],
      results_first_posted_date: status['ResultsFirstPostDateStruct']['ResultsFirstPostDate'],
      results_first_posted_date_type: status['ResultsFirstPostDateStruct']['ResultsFirstPostDateType'],
      disposition_first_submitted_qc_date: status['DispFirstSubmitQCDate'],
      disposition_first_posted_date: status['DispFirstPostDateStruct']['DispFirstPostDate'],
      disposition_first_posted_date_type: status['DispFirstPostDateStruct']['DispFirstPostDateType'],
      last_update_submitted_qc_date: status['LastUpdateSubmitDate'],
      last_update_posted_date: status['LastUpdatePostDateStruct']['LastUpdatePostDate'],
      last_update_posted_date_type: status['LastUpdatePostDateStruct']['LastUpdatePostDateType'],
      start_month_year: nil,
      start_date_type: status['StartDateStruct']['StartDateType'],
      start_date: status['StartDateStruct']['StartDate'],
      verification_month_year: status['StatusVerifiedDate'],
      verification_date: status['StatusVerifiedDate'],
      completion_month_year: nil,
      completion_date_type: status['CompletionDateStruct']['CompletionDateType'],
      completion_date: status['CompletionDateStruct']['CompletionDate'],
      primary_completion_month_year: nil,
      primary_completion_date_type: status['PrimaryCompletionDateStruct']['PrimaryCompletionDateType'],
      primary_completion_date: status['PrimaryCompletionDateStruct']['PrimaryCompletionDate'],
      target_duration: design['TargetDuration'],
      study_type: design['StudyType'],
      acronym: ident['Acronym'],
      baseline_population: baseline['BaselinePopulationDescription'],
      brief_title: ident['BriefTitle'],
      official_title: ident['OfficialTitle'],
      overall_status: status['OverallStatus'],
      last_known_status: status['LastKnownStatus'],
      phase: design['PhaseList']['Phase'],
      enrollment: design['EnrollmentInfo']['EnrollmentCount'],
      enrollment_type: design['EnrollmentInfo']['EnrollmentType'],
      source: nil,
      limitations_and_caveats: results['MoreInfoModule']['LimitationsAndCaveats'],
      number_of_arms: nil,
      number_of_groups: nil,
      why_stopped: status['WhyStopped'],
      has_expanded_access: nil,
      expanded_access_type_individual: design['ExpandedAccessTypes']['ExpAccTypeIndividual'],
      expanded_access_type_intermediate: design['ExpandedAccessTypes']['ExpAccTypeIntermediate'],
      expanded_access_type_treatment: design['ExpandedAccessTypes']['ExpAccTypeTreatment'],
      has_dmc: oversight['OversightHasDMC'],
      is_fda_regulated_drug: oversight['IsFDARegulatedDrug'],
      is_fda_regulated_device: oversight['IsFDARegulatedDevice'],
      is_unapproved_device: nil,
      is_ppsd: nil,
      is_us_export: nil,
      biospec_retention: design['BioSpec']['BioSpecRetention'],
      biospec_description: design['BioSpec']['BioSpecDescription '],
      ipd_time_frame: ipd_sharing['IPDSharingTimeFrame'],
      ipd_access_criteria: ipd_sharing['IPDSharingAccessCriteria'],
      ipd_url: ipd_sharing['IPDSharingURL'],
      plan_to_share_ipd: ipd_sharing['IPDSharing'],
      plan_to_share_ipd_description: ipd_sharing['IPDSharingDescription']
    }
  end

  def self.study_structure
    {
      "StudyStructure":{
        "APIVrs":"1.01.02",
        "ElmtDefs":{
          "Study":{"type":"Object",
            "ProtocolSection":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html",
              "IdentificationModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#identification",
                "NCTId":{"type":"String"},
                "NCTIdAliasList":{"type":"Array",
                  "NCTIdAlias":{"type":"String"}
                },
                "OrgStudyIdInfo":{"type":"Object",
                  "OrgStudyId":{"type":"String"},
                  "OrgStudyIdType":{"type":"String"},
                  "OrgStudyIdDomain":{"type":"String"},
                  "OrgStudyIdLink":{"type":"String"}
                },
                "SecondaryIdInfoList":{"type":"Array",
                  "SecondaryIdInfo":{"type":"Object",
                    "SecondaryId":{"type":"String"},
                    "SecondaryIdType":{"type":"String"},
                    "SecondaryIdDomain":{"type":"String"},
                    "SecondaryIdLink":{"type":"String"}
                  }
                },
                "Organization":{"type":"Object",
                  "OrgFullName":{"type":"String"},
                  "OrgClass":{"type":"String"}
                },
                "BriefTitle":{"type":"String"},
                "OfficialTitle":{"type":"String"},
                "Acronym":{"type":"String"}
              },
              "StatusModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#status",
                "StatusVerifiedDate":{"type":"String"},
                "OverallStatus":{"type":"String"},
                "LastKnownStatus":{"type":"String"},
                "DelayedPosting":{"type":"String"},
                "WhyStopped":{"type":"String"},
                "ExpandedAccessInfo":{"type":"Object",
                  "HasExpandedAccess":{"type":"String"},
                  "ExpandedAccessNCTId":{"type":"String"},
                  "ExpandedAccessStatusForNCTId":{"type":"String"}
                },
                "StartDateStruct":{"type":"Object",
                  "StartDate":{"type":"String"},
                  "StartDateType":{"type":"String"}
                },
                "PrimaryCompletionDateStruct":{"type":"Object",
                  "PrimaryCompletionDate":{"type":"String"},
                  "PrimaryCompletionDateType":{"type":"String"}
                },
                "CompletionDateStruct":{"type":"Object",
                  "CompletionDate":{"type":"String"},
                  "CompletionDateType":{"type":"String"}
                },
                "StudyFirstSubmitDate":{"type":"String"},
                "StudyFirstSubmitQCDate":{"type":"String"},
                "StudyFirstPostDateStruct":{"type":"Object",
                  "StudyFirstPostDate":{"type":"String"},
                  "StudyFirstPostDateType":{"type":"String"}
                },
                "ResultsFirstSubmitDate":{"type":"String"},
                "ResultsFirstSubmitQCDate":{"type":"String"},
                "ResultsFirstPostDateStruct":{"type":"Object",
                  "ResultsFirstPostDate":{"type":"String"},
                  "ResultsFirstPostDateType":{"type":"String"}
                },
                "DispFirstSubmitDate":{"type":"String"},
                "DispFirstSubmitQCDate":{"type":"String"},
                "DispFirstPostDateStruct":{"type":"Object",
                  "DispFirstPostDate":{"type":"String"},
                  "DispFirstPostDateType":{"type":"String"}
                },
                "LastUpdateSubmitDate":{"type":"String"},
                "LastUpdatePostDateStruct":{"type":"Object",
                  "LastUpdatePostDate":{"type":"String"},
                  "LastUpdatePostDateType":{"type":"String"}
                }
              },
              "SponsorCollaboratorsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#sponsors",
                "ResponsibleParty":{"type":"Object",
                  "ResponsiblePartyType":{"type":"String"},
                  "ResponsiblePartyInvestigatorFullName":{"type":"String"},
                  "ResponsiblePartyInvestigatorTitle":{"type":"String"},
                  "ResponsiblePartyInvestigatorAffiliation":{"type":"String"},
                  "ResponsiblePartyOldNameTitle":{"type":"String"},
                  "ResponsiblePartyOldOrganization":{"type":"String"}
                },
                "LeadSponsor":{"type":"Object",
                  "LeadSponsorName":{"type":"String"},
                  "LeadSponsorClass":{"type":"String"}
                },
                "CollaboratorList":{"type":"Array",
                  "Collaborator":{"type":"Object",
                    "CollaboratorName":{"type":"String"},
                    "CollaboratorClass":{"type":"String"}
                  }
                }
              },
              "OversightModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#oversight",
                "OversightHasDMC":{"type":"String"},
                "IsFDARegulatedDrug":{"type":"String"},
                "IsFDARegulatedDevice":{"type":"String"},
                "IsUnapprovedDevice":{"type":"String"},
                "IsPPSD":{"type":"String"},
                "IsUSExport":{"type":"String"}
              },
              "DescriptionModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#description",
                "BriefSummary":{"type":"String"},
                "DetailedDescription":{"type":"String"}
              },
              "ConditionsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#Conditions",
                "ConditionList":{"type":"Array",
                  "Condition":{"type":"String"}
                },
                "KeywordList":{"type":"Array",
                  "Keyword":{"type":"String"}
                }
              },
              "DesignModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#StudyDesign",
                "StudyType":{"type":"String","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#StudyType"},
                "ExpandedAccessTypes":{"type":"Object",
                  "ExpAccTypeIndividual":{"type":"String"},
                  "ExpAccTypeIntermediate":{"type":"String"},
                  "ExpAccTypeTreatment":{"type":"String"}
                },
                "PatientRegistry":{"type":"String"},
                "TargetDuration":{"type":"String"},
                "PhaseList":{"type":"Array",
                  "Phase":{"type":"String"}
                },
                "DesignInfo":{"type":"Object",
                  "DesignAllocation":{"type":"String"},
                  "DesignInterventionModel":{"type":"String"},
                  "DesignInterventionModelDescription":{"type":"String"},
                  "DesignPrimaryPurpose":{"type":"String"},
                  "DesignObservationalModelList":{"type":"Array",
                    "DesignObservationalModel":{"type":"String"}
                  },
                  "DesignTimePerspectiveList":{"type":"Array",
                    "DesignTimePerspective":{"type":"String"}
                  },
                  "DesignMaskingInfo":{"type":"Object",
                    "DesignMasking":{"type":"String"},
                    "DesignMaskingDescription":{"type":"String"},
                    "DesignWhoMaskedList":{"type":"Array",
                      "DesignWhoMasked":{"type":"String"}
                    }
                  }
                },
                "BioSpec":{"type":"Object",
                  "BioSpecRetention":{"type":"String"},
                  "BioSpecDescription":{"type":"String"}
                },
                "EnrollmentInfo":{"type":"Object",
                  "EnrollmentCount":{"type":"String"},
                  "EnrollmentType":{"type":"String"}
                }
              },
              "ArmsInterventionsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#ArmsGroupsInterventions",
                "ArmGroupList":{"type":"Array",
                  "ArmGroup":{"type":"Object",
                    "ArmGroupLabel":{"type":"String"},
                    "ArmGroupType":{"type":"String"},
                    "ArmGroupDescription":{"type":"String"},
                    "ArmGroupInterventionList":{"type":"Array",
                      "ArmGroupInterventionName":{"type":"String"}
                    }
                  }
                },
                "InterventionList":{"type":"Array",
                  "Intervention":{"type":"Object",
                    "InterventionType":{"type":"String"},
                    "InterventionName":{"type":"String"},
                    "InterventionDescription":{"type":"String"},
                    "InterventionArmGroupLabelList":{"type":"Array",
                      "InterventionArmGroupLabel":{"type":"String"}
                    },
                    "InterventionOtherNameList":{"type":"Array",
                      "InterventionOtherName":{"type":"String"}
                    }
                  }
                }
              },
              "OutcomesModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#Outcomes",
                "PrimaryOutcomeList":{"type":"Array",
                  "PrimaryOutcome":{"type":"Object",
                    "PrimaryOutcomeMeasure":{"type":"String"},
                    "PrimaryOutcomeDescription":{"type":"String"},
                    "PrimaryOutcomeTimeFrame":{"type":"String"}
                  }
                },
                "SecondaryOutcomeList":{"type":"Array",
                  "SecondaryOutcome":{"type":"Object",
                    "SecondaryOutcomeMeasure":{"type":"String"},
                    "SecondaryOutcomeDescription":{"type":"String"},
                    "SecondaryOutcomeTimeFrame":{"type":"String"}
                  }
                },
                "OtherOutcomeList":{"type":"Array",
                  "OtherOutcome":{"type":"Object",
                    "OtherOutcomeMeasure":{"type":"String"},
                    "OtherOutcomeDescription":{"type":"String"},
                    "OtherOutcomeTimeFrame":{"type":"String"}
                  }
                }
              },
              "EligibilityModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#Eligibility",
                "EligibilityCriteria":{"type":"String"},
                "HealthyVolunteers":{"type":"String"},
                "Gender":{"type":"String"},
                "GenderBased":{"type":"String"},
                "GenderDescription":{"type":"String"},
                "MinimumAge":{"type":"String"},
                "MaximumAge":{"type":"String"},
                "StdAgeList":{"type":"Array",
                  "StdAge":{"type":"String"}
                },
                "StudyPopulation":{"type":"String"},
                "SamplingMethod":{"type":"String"}
              },
              "ContactsLocationsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#Locations",
                "CentralContactList":{"type":"Array",
                  "CentralContact":{"type":"Object",
                    "CentralContactName":{"type":"String"},
                    "CentralContactRole":{"type":"String"},
                    "CentralContactPhone":{"type":"String"},
                    "CentralContactPhoneExt":{"type":"String"},
                    "CentralContactEMail":{"type":"String"}
                  }
                },
                "OverallOfficialList":{"type":"Array",
                  "OverallOfficial":{"type":"Object",
                    "OverallOfficialName":{"type":"String"},
                    "OverallOfficialAffiliation":{"type":"String"},
                    "OverallOfficialRole":{"type":"String"}
                  }
                },
                "LocationList":{"type":"Array",
                  "Location":{"type":"Object",
                    "LocationFacility":{"type":"String"},
                    "LocationStatus":{"type":"String"},
                    "LocationCity":{"type":"String"},
                    "LocationState":{"type":"String"},
                    "LocationZip":{"type":"String"},
                    "LocationCountry":{"type":"String"},
                    "LocationContactList":{"type":"Array",
                      "LocationContact":{"type":"Object",
                        "LocationContactName":{"type":"String"},
                        "LocationContactRole":{"type":"String"},
                        "LocationContactPhone":{"type":"String"},
                        "LocationContactPhoneExt":{"type":"String"},
                        "LocationContactEMail":{"type":"String"}
                      }
                    }
                  }
                }
              },
              "ReferencesModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#References",
                "ReferenceList":{"type":"Array",
                  "Reference":{"type":"Object",
                    "ReferencePMID":{"type":"String"},
                    "ReferenceType":{"type":"String"},
                    "ReferenceCitation":{"type":"String"},
                    "RetractionList":{"type":"Array",
                      "Retraction":{"type":"Object",
                        "RetractionPMID":{"type":"String"},
                        "RetractionSource":{"type":"String"}
                      }
                    }
                  }
                },
                "SeeAlsoLinkList":{"type":"Array",
                  "SeeAlsoLink":{"type":"Object",
                    "SeeAlsoLinkLabel":{"type":"String"},
                    "SeeAlsoLinkURL":{"type":"String"}
                  }
                },
                "AvailIPDList":{"type":"Array",
                  "AvailIPD":{"type":"Object",
                    "AvailIPDId":{"type":"String"},
                    "AvailIPDType":{"type":"String"},
                    "AvailIPDURL":{"type":"String"},
                    "AvailIPDComment":{"type":"String"}
                  }
                }
              },
              "IPDSharingStatementModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/definitions.html#IPDSharing",
                "IPDSharing":{"type":"String"},
                "IPDSharingDescription":{"type":"String"},
                "IPDSharingInfoTypeList":{"type":"Array",
                  "IPDSharingInfoType":{"type":"String"}
                },
                "IPDSharingTimeFrame":{"type":"String"},
                "IPDSharingAccessCriteria":{"type":"String"},
                "IPDSharingURL":{"type":"String"}
              }
            },
            "ResultsSection":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html",
              "ParticipantFlowModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_ParticipantFlow",
                "FlowPreAssignmentDetails":{"type":"String"},
                "FlowRecruitmentDetails":{"type":"String"},
                "FlowTypeUnitsAnalyzed":{"type":"String"},
                "FlowGroupList":{"type":"Array",
                  "FlowGroup":{"type":"Object",
                    "FlowGroupId":{"type":"String"},
                    "FlowGroupTitle":{"type":"String"},
                    "FlowGroupDescription":{"type":"String"}
                  }
                },
                "FlowPeriodList":{"type":"Array",
                  "FlowPeriod":{"type":"Object",
                    "FlowPeriodTitle":{"type":"String"},
                    "FlowMilestoneList":{"type":"Array",
                      "FlowMilestone":{"type":"Object",
                        "FlowMilestoneType":{"type":"String"},
                        "FlowMilestoneComment":{"type":"String"},
                        "FlowAchievementList":{"type":"Array",
                          "FlowAchievement":{"type":"Object",
                            "FlowAchievementGroupId":{"type":"String"},
                            "FlowAchievementComment":{"type":"String"},
                            "FlowAchievementNumSubjects":{"type":"String"},
                            "FlowAchievementNumUnits":{"type":"String"}
                          }
                        }
                      }
                    },
                    "FlowDropWithdrawList":{"type":"Array",
                      "FlowDropWithdraw":{"type":"Object",
                        "FlowDropWithdrawType":{"type":"String"},
                        "FlowDropWithdrawComment":{"type":"String"},
                        "FlowReasonList":{"type":"Array",
                          "FlowReason":{"type":"Object",
                            "FlowReasonGroupId":{"type":"String"},
                            "FlowReasonComment":{"type":"String"},
                            "FlowReasonNumSubjects":{"type":"String"},
                            "FlowReasonNumUnits":{"type":"String"}
                          }
                        }
                      }
                    }
                  }
                }
              },
              "BaselineCharacteristicsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_Baseline",
                "BaselinePopulationDescription":{"type":"String"},
                "BaselineTypeUnitsAnalyzed":{"type":"String"},
                "BaselineGroupList":{"type":"Array",
                  "BaselineGroup":{"type":"Object",
                    "BaselineGroupId":{"type":"String"},
                    "BaselineGroupTitle":{"type":"String"},
                    "BaselineGroupDescription":{"type":"String"}
                  }
                },
                "BaselineDenomList":{"type":"Array",
                  "BaselineDenom":{"type":"Object",
                    "BaselineDenomUnits":{"type":"String"},
                    "BaselineDenomCountList":{"type":"Array",
                      "BaselineDenomCount":{"type":"Object",
                        "BaselineDenomCountGroupId":{"type":"String"},
                        "BaselineDenomCountValue":{"type":"String"}
                      }
                    }
                  }
                },
                "BaselineMeasureList":{"type":"Array",
                  "BaselineMeasure":{"type":"Object",
                    "BaselineMeasureTitle":{"type":"String"},
                    "BaselineMeasureDescription":{"type":"String"},
                    "BaselineMeasurePopulationDescription":{"type":"String"},
                    "BaselineMeasureParamType":{"type":"String"},
                    "BaselineMeasureDispersionType":{"type":"String"},
                    "BaselineMeasureUnitOfMeasure":{"type":"String"},
                    "BaselineMeasureCalculatePct":{"type":"String"},
                    "BaselineMeasureDenomUnitsSelected":{"type":"String"},
                    "BaselineMeasureDenomList":{"type":"Array",
                      "BaselineMeasureDenom":{"type":"Object",
                        "BaselineMeasureDenomUnits":{"type":"String"},
                        "BaselineMeasureDenomCountList":{"type":"Array",
                          "BaselineMeasureDenomCount":{"type":"Object",
                            "BaselineMeasureDenomCountGroupId":{"type":"String"},
                            "BaselineMeasureDenomCountValue":{"type":"String"}
                          }
                        }
                      }
                    },
                    "BaselineClassList":{"type":"Array",
                      "BaselineClass":{"type":"Object",
                        "BaselineClassTitle":{"type":"String"},
                        "BaselineClassDenomList":{"type":"Array",
                          "BaselineClassDenom":{"type":"Object",
                            "BaselineClassDenomUnits":{"type":"String"},
                            "BaselineClassDenomCountList":{"type":"Array",
                              "BaselineClassDenomCount":{"type":"Object",
                                "BaselineClassDenomCountGroupId":{"type":"String"},
                                "BaselineClassDenomCountValue":{"type":"String"}
                              }
                            }
                          }
                        },
                        "BaselineCategoryList":{"type":"Array",
                          "BaselineCategory":{"type":"Object",
                            "BaselineCategoryTitle":{"type":"String"},
                            "BaselineMeasurementList":{"type":"Array",
                              "BaselineMeasurement":{"type":"Object",
                                "BaselineMeasurementGroupId":{"type":"String"},
                                "BaselineMeasurementValue":{"type":"String"},
                                "BaselineMeasurementSpread":{"type":"String"},
                                "BaselineMeasurementLowerLimit":{"type":"String"},
                                "BaselineMeasurementUpperLimit":{"type":"String"},
                                "BaselineMeasurementComment":{"type":"String"}
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "OutcomeMeasuresModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_Outcome_Measure",
                "OutcomeMeasureList":{"type":"Array",
                  "OutcomeMeasure":{"type":"Object",
                    "OutcomeMeasureType":{"type":"String"},
                    "OutcomeMeasureTitle":{"type":"String"},
                    "OutcomeMeasureDescription":{"type":"String"},
                    "OutcomeMeasurePopulationDescription":{"type":"String"},
                    "OutcomeMeasureReportingStatus":{"type":"String"},
                    "OutcomeMeasureAnticipatedPostingDate":{"type":"String"},
                    "OutcomeMeasureParamType":{"type":"String"},
                    "OutcomeMeasureDispersionType":{"type":"String"},
                    "OutcomeMeasureUnitOfMeasure":{"type":"String"},
                    "OutcomeMeasureCalculatePct":{"type":"String"},
                    "OutcomeMeasureTimeFrame":{"type":"String"},
                    "OutcomeMeasureTypeUnitsAnalyzed":{"type":"String"},
                    "OutcomeMeasureDenomUnitsSelected":{"type":"String"},
                    "OutcomeGroupList":{"type":"Array",
                      "OutcomeGroup":{"type":"Object",
                        "OutcomeGroupId":{"type":"String"},
                        "OutcomeGroupTitle":{"type":"String"},
                        "OutcomeGroupDescription":{"type":"String"}
                      }
                    },
                    "OutcomeDenomList":{"type":"Array",
                      "OutcomeDenom":{"type":"Object",
                        "OutcomeDenomUnits":{"type":"String"},
                        "OutcomeDenomCountList":{"type":"Array",
                          "OutcomeDenomCount":{"type":"Object",
                            "OutcomeDenomCountGroupId":{"type":"String"},
                            "OutcomeDenomCountValue":{"type":"String"}
                          }
                        }
                      }
                    },
                    "OutcomeClassList":{"type":"Array",
                      "OutcomeClass":{"type":"Object",
                        "OutcomeClassTitle":{"type":"String"},
                        "OutcomeClassDenomList":{"type":"Array",
                          "OutcomeClassDenom":{"type":"Object",
                            "OutcomeClassDenomUnits":{"type":"String"},
                            "OutcomeClassDenomCountList":{"type":"Array",
                              "OutcomeClassDenomCount":{"type":"Object",
                                "OutcomeClassDenomCountGroupId":{"type":"String"},
                                "OutcomeClassDenomCountValue":{"type":"String"}
                              }
                            }
                          }
                        },
                        "OutcomeCategoryList":{"type":"Array",
                          "OutcomeCategory":{"type":"Object",
                            "OutcomeCategoryTitle":{"type":"String"},
                            "OutcomeMeasurementList":{"type":"Array",
                              "OutcomeMeasurement":{"type":"Object",
                                "OutcomeMeasurementGroupId":{"type":"String"},
                                "OutcomeMeasurementValue":{"type":"String"},
                                "OutcomeMeasurementSpread":{"type":"String"},
                                "OutcomeMeasurementLowerLimit":{"type":"String"},
                                "OutcomeMeasurementUpperLimit":{"type":"String"},
                                "OutcomeMeasurementComment":{"type":"String"}
                              }
                            }
                          }
                        }
                      }
                    },
                    "OutcomeAnalysisList":{"type":"Array","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_Outcome_Analysis",
                      "OutcomeAnalysis":{"type":"Object",
                        "OutcomeAnalysisGroupIdList":{"type":"Array",
                          "OutcomeAnalysisGroupId":{"type":"String"}
                        },
                        "OutcomeAnalysisGroupDescription":{"type":"String"},
                        "OutcomeAnalysisTestedNonInferiority":{"type":"String"},
                        "OutcomeAnalysisNonInferiorityType":{"type":"String"},
                        "OutcomeAnalysisNonInferiorityComment":{"type":"String"},
                        "OutcomeAnalysisPValue":{"type":"String"},
                        "OutcomeAnalysisPValueComment":{"type":"String"},
                        "OutcomeAnalysisStatisticalMethod":{"type":"String"},
                        "OutcomeAnalysisStatisticalComment":{"type":"String"},
                        "OutcomeAnalysisParamType":{"type":"String"},
                        "OutcomeAnalysisParamValue":{"type":"String"},
                        "OutcomeAnalysisCIPctValue":{"type":"String"},
                        "OutcomeAnalysisCINumSides":{"type":"String"},
                        "OutcomeAnalysisCILowerLimit":{"type":"String"},
                        "OutcomeAnalysisCIUpperLimit":{"type":"String"},
                        "OutcomeAnalysisCILowerLimitComment":{"type":"String"},
                        "OutcomeAnalysisCIUpperLimitComment":{"type":"String"},
                        "OutcomeAnalysisDispersionType":{"type":"String"},
                        "OutcomeAnalysisDispersionValue":{"type":"String"},
                        "OutcomeAnalysisEstimateComment":{"type":"String"},
                        "OutcomeAnalysisOtherAnalysisDescription":{"type":"String"}
                      }
                    }
                  }
                }
              },
              "AdverseEventsModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_AdverseEvents",
                "EventsFrequencyThreshold":{"type":"String"},
                "EventsTimeFrame":{"type":"String"},
                "EventsDescription":{"type":"String"},
                "EventGroupList":{"type":"Array",
                  "EventGroup":{"type":"Object",
                    "EventGroupId":{"type":"String"},
                    "EventGroupTitle":{"type":"String"},
                    "EventGroupDescription":{"type":"String"},
                    "EventGroupDeathsNumAffected":{"type":"String"},
                    "EventGroupDeathsNumAtRisk":{"type":"String"},
                    "EventGroupSeriousNumAffected":{"type":"String"},
                    "EventGroupSeriousNumAtRisk":{"type":"String"},
                    "EventGroupOtherNumAffected":{"type":"String"},
                    "EventGroupOtherNumAtRisk":{"type":"String"}
                  }
                },
                "SeriousEventList":{"type":"Array",
                  "SeriousEvent":{"type":"Object",
                    "SeriousEventTerm":{"type":"String"},
                    "SeriousEventOrganSystem":{"type":"String"},
                    "SeriousEventSourceVocabulary":{"type":"String"},
                    "SeriousEventAssessmentType":{"type":"String"},
                    "SeriousEventNotes":{"type":"String"},
                    "SeriousEventStatsList":{"type":"Array",
                      "SeriousEventStats":{"type":"Object",
                        "SeriousEventStatsGroupId":{"type":"String"},
                        "SeriousEventStatsNumEvents":{"type":"String"},
                        "SeriousEventStatsNumAffected":{"type":"String"},
                        "SeriousEventStatsNumAtRisk":{"type":"String"}
                      }
                    }
                  }
                },
                "OtherEventList":{"type":"Array",
                  "OtherEvent":{"type":"Object",
                    "OtherEventTerm":{"type":"String"},
                    "OtherEventOrganSystem":{"type":"String"},
                    "OtherEventSourceVocabulary":{"type":"String"},
                    "OtherEventAssessmentType":{"type":"String"},
                    "OtherEventNotes":{"type":"String"},
                    "OtherEventStatsList":{"type":"Array",
                      "OtherEventStats":{"type":"Object",
                        "OtherEventStatsGroupId":{"type":"String"},
                        "OtherEventStatsNumEvents":{"type":"String"},
                        "OtherEventStatsNumAffected":{"type":"String"},
                        "OtherEventStatsNumAtRisk":{"type":"String"}
                      }
                    }
                  }
                }
              },
              "MoreInfoModule":{"type":"Object",
                "LimitationsAndCaveats":{"type":"String","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_LimitationsAndCaveats_description"},
                "CertainAgreement":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_CertainAgreement",
                  "AgreementPISponsorEmployee":{"type":"String"},
                  "AgreementRestrictionType":{"type":"String"},
                  "AgreementRestrictiveAgreement":{"type":"String"},
                  "AgreementOtherDetails":{"type":"String"}
                },
                "PointOfContact":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#Result_PointOfContact",
                  "PointOfContactTitle":{"type":"String"},
                  "PointOfContactOrganization":{"type":"String"},
                  "PointOfContactEMail":{"type":"String"},
                  "PointOfContactPhone":{"type":"String"},
                  "PointOfContactPhoneExt":{"type":"String"}
                }
              }
            },
            "AnnotationSection":{"type":"Object",
              "AnnotationModule":{"type":"Object",
                "UnpostedAnnotation":{"type":"Object",
                  "UnpostedResponsibleParty":{"type":"String"},
                  "UnpostedEventList":{"type":"Array",
                    "UnpostedEvent":{"type":"Object",
                      "UnpostedEventType":{"type":"String"},
                      "UnpostedEventDate":{"type":"String"}
                    }
                  }
                }
              }
            },
            "DocumentSection":{"type":"Object",
              "LargeDocumentModule":{"type":"Object","dedLink":"https://prsinfo.clinicaltrials.gov/results_definitions.html#DocumentUploadLabel",
                "LargeDocList":{"type":"Array",
                  "LargeDoc":{"type":"Object",
                    "LargeDocTypeAbbrev":{"type":"String"},
                    "LargeDocHasProtocol":{"type":"String"},
                    "LargeDocHasSAP":{"type":"String"},
                    "LargeDocHasICF":{"type":"String"},
                    "LargeDocLabel":{"type":"String"},
                    "LargeDocDate":{"type":"String"},
                    "LargeDocUploadDate":{"type":"String"},
                    "LargeDocFilename":{"type":"String"}
                  }
                }
              }
            },
            "DerivedSection":{"type":"Object",
              "MiscInfoModule":{"type":"Object",
                "VersionHolder":{"type":"String"},
                "RemovedCountryList":{"type":"Array",
                  "RemovedCountry":{"type":"String"}
                }
              },
              "ConditionBrowseModule":{"type":"Object",
                "ConditionMeshList":{"type":"Array",
                  "ConditionMesh":{"type":"Object",
                    "ConditionMeshId":{"type":"String"},
                    "ConditionMeshTerm":{"type":"String"}
                  }
                },
                "ConditionAncestorList":{"type":"Array",
                  "ConditionAncestor":{"type":"Object",
                    "ConditionAncestorId":{"type":"String"},
                    "ConditionAncestorTerm":{"type":"String"}
                  }
                },
                "ConditionBrowseLeafList":{"type":"Array",
                  "ConditionBrowseLeaf":{"type":"Object",
                    "ConditionBrowseLeafId":{"type":"String"},
                    "ConditionBrowseLeafName":{"type":"String"},
                    "ConditionBrowseLeafAsFound":{"type":"String"},
                    "ConditionBrowseLeafRelevance":{"type":"String"}
                  }
                },
                "ConditionBrowseBranchList":{"type":"Array",
                  "ConditionBrowseBranch":{"type":"Object",
                    "ConditionBrowseBranchAbbrev":{"type":"String"},
                    "ConditionBrowseBranchName":{"type":"String"}
                  }
                }
              },
              "InterventionBrowseModule":{"type":"Object",
                "InterventionMeshList":{"type":"Array",
                  "InterventionMesh":{"type":"Object",
                    "InterventionMeshId":{"type":"String"},
                    "InterventionMeshTerm":{"type":"String"}
                  }
                },
                "InterventionAncestorList":{"type":"Array",
                  "InterventionAncestor":{"type":"Object",
                    "InterventionAncestorId":{"type":"String"},
                    "InterventionAncestorTerm":{"type":"String"}
                  }
                },
                "InterventionBrowseLeafList":{"type":"Array",
                  "InterventionBrowseLeaf":{"type":"Object",
                    "InterventionBrowseLeafId":{"type":"String"},
                    "InterventionBrowseLeafName":{"type":"String"},
                    "InterventionBrowseLeafAsFound":{"type":"String"},
                    "InterventionBrowseLeafRelevance":{"type":"String"}
                  }
                },
                "InterventionBrowseBranchList":{"type":"Array",
                  "InterventionBrowseBranch":{"type":"Object",
                    "InterventionBrowseBranchAbbrev":{"type":"String"},
                    "InterventionBrowseBranchName":{"type":"String"}
                  }
                }
              }
            }
          }
        }
      }
    }.stringify_keys
  end

  def convert_date(date)
    return nil if date.nil?
    return date.to_date.end_of_month if date.is_missing_the_day?
    return data.to_date
  end
end
