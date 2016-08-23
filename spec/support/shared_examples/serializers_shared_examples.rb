shared_examples 'a serialized study' do
  let(:serializer) { described_class.new resource }
  subject { JSON.parse(serializer.to_json) }

  it 'should serialize to json' do
    expect{subject}.to_not raise_error
  end

  it 'should have expected keys and values' do
    is_expected.to have_key('study')
    serialized_study = subject['study']
    %w(
      nct_id

      first_received_date
      last_changed_date
      first_received_results_date
      first_received_results_disposition_date

      start_month_year
      verification_month_year
      primary_completion_month_year
      completion_month_year
      nlm_download_date_description
      completion_month_year
      completion_date_type
      primary_completion_date_type
      study_type
      overall_status
      phase
      target_duration
      enrollment
      enrollment_type
      source
      biospec_retention
      limitations_and_caveats
      description
      acronym
      number_of_arms
      number_of_groups
      why_stopped
      has_expanded_access
      has_dmc
      is_section_801
      is_fda_regulated
      brief_title
      official_title
      biospec_description
      created_at
      updated_at
    ).each do |expected_key|
      expect(serialized_study).to have_key(expected_key)
    end
    expect(serialized_study['nct_id']).to eq(resource.nct_id)
    %w(
      first_received_date
      last_changed_date
      first_received_results_date
      first_received_results_disposition_date
    ).each do |date_key|
      if serialized_study[date_key]
        expect(Date.parse(serialized_study[date_key])).to eq(resource.send(date_key))
      else
        expect(serialized_study[date_key]).to eq(resource.send(date_key))
      end
    end

    expect(serialized_study['start_month_year']).to eq(resource.start_month_year)
    expect(serialized_study['verification_month_year']).to eq(resource.verification_month_year)
    expect(serialized_study['primary_completion_month_year']).to eq(resource.primary_completion_month_year)
    expect(serialized_study['completion_month_year']).to eq(resource.completion_month_year)
    expect(serialized_study['nlm_download_date_description']).to eq(resource.nlm_download_date_description)
    expect(serialized_study['completion_date_type']).to eq(resource.completion_date_type)
    expect(serialized_study['primary_completion_date_type']).to eq(resource.primary_completion_date_type)
    expect(serialized_study['study_type']).to eq(resource.study_type)
    expect(serialized_study['overall_status']).to eq(resource.overall_status)
    expect(serialized_study['phase']).to eq(resource.phase)
    expect(serialized_study['target_duration']).to eq(resource.target_duration)
    expect(serialized_study['enrollment']).to eq(resource.enrollment)
    expect(serialized_study['enrollment_type']).to eq(resource.enrollment_type)
    expect(serialized_study['source']).to eq(resource.source)
    expect(serialized_study['biospec_retention']).to eq(resource.biospec_retention)
    expect(serialized_study['limitations_and_caveats']).to eq(resource.limitations_and_caveats)
    expect(serialized_study['description']).to eq(resource.description)
    expect(serialized_study['acronym']).to eq(resource.acronym)
    expect(serialized_study['number_of_arms']).to eq(resource.number_of_arms)
    expect(serialized_study['number_of_groups']).to eq(resource.number_of_groups)
    expect(serialized_study['why_stopped']).to eq(resource.why_stopped)
    expect(serialized_study['has_expanded_access']).to eq(resource.has_expanded_access)
    expect(serialized_study['has_dmc']).to eq(resource.has_dmc)
    expect(serialized_study['is_section_801']).to eq(resource.is_section_801)
    expect(serialized_study['is_fda_regulated']).to eq(resource.is_fda_regulated)
    expect(serialized_study['brief_title']).to eq(resource.brief_title)
    expect(serialized_study['official_title']).to eq(resource.official_title)
    expect(serialized_study['biospec_description']).to eq(resource.biospec_description)
    expect(DateTime.parse(serialized_study['created_at']).to_i).to eq(resource.created_at.to_i)
    expect(DateTime.parse(serialized_study['updated_at']).to_i).to eq(resource.updated_at.to_i)
  end
end
