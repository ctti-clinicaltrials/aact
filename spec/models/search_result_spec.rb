require 'rails_helper'

RSpec.describe SearchResult, type: :model do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'} }
  let(:covid_batch) { File.read('spec/support/xml_data/covid_search.xml') }
  let(:empty_batch) { File.read('spec/support/xml_data/empty_search.xml') }
  let(:covid_url) { 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=0' }
  let(:covid_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => covid_batch, :headers => {}) }
  let(:empty_search_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => empty_batch, :headers => {}) }
  
  context 'when there are search_results' do
    before do
      covid_stub
      Util::DbManager.new.add_indexes_and_constraints
      covid_search = StudySearch.make_covid_search
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04452435_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04452435'}).create
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT02798588.xml"))
      @etic_study=Study.new({xml: xml, nct_id: 'NCT02798588'}).create
      covid_search.load_update
      @folder = "./public/static/exported_files/covid-19"
    end
    after do
      `rm -r #{@folder}`
    end
    describe ':make_tsv' do
      it 'makes a tsv file' do
        SearchResult.make_tsv
        expect(Dir.exists?(@folder)).to be true
        expect(Dir.empty?(@folder)).to be false
      end
      it 'creates a tsv with the right content' do
        SearchResult.make_tsv
        filenames = Dir.entries(@folder)
        filename = filenames.select{|name| name =~ /covid/}.first
        content = File.open("#{@folder}/#{filename}").read
        expect(content).to include @covid_study.nct_id
        expect(content).to_not include @etic_study.nct_id
        expect(content).to include @covid_study.brief_title
        expect(content).to include @covid_study.overall_status
        expect(content).to include @covid_study.study_type
      end
    end
    describe ':study_values' do
      before do
        @content = SearchResult.study_values(@covid_study)
      end
      it 'is an array' do
        expect(@content.kind_of?(Array)).to be true
      end
      it 'has the right nct_id' do
        expect(@content).to include @covid_study.nct_id
        expect(@content).to_not include @etic_study.nct_id
      end
      it 'has the right title' do
        expect(@content).to include @covid_study.brief_title
      end
      it 'has the right acronym' do
        expect(@content).to include @covid_study.acronym
      end
      it 'has the right other_ids' do
        expect(@content).to include @covid_study.id_information.pluck(:id_value).join('|')
      end
      it 'has the right url' do
        expect(@content).to include "https://ClinicalTrials.gov/show/#{@covid_study.nct_id}"
      end
      it 'has the right status' do
        expect(@content).to include @covid_study.overall_status
      end
      it 'has the right reason it stopped' do
        expect(@content).to include @covid_study.why_stopped
      end
      it 'has the right funders and sponsors' do
        sponsors = @covid_study.sponsors
        grouped = sponsors.group_by(&:lead_or_collaborator)
        lead = grouped['lead'].first
        collaborators = grouped['collaborator']
        collab_names = collaborators.map{|collab| "#{collab.name}[#{collab.agency_class}]"}.join('|') if collaborators
        expect(@content).to include sponsors.pluck(:agency_class).uniq.join('|')
        expect(@content).to include sponsors.pluck(:name).join('|')
        expect(@content).to include lead ? "#{lead.name}[#{lead.agency_class}]" : nil
        expect(@content).to include collab_names
      end
      it 'has the right study type' do
        expect(@content).to include @covid_study.study_type
      end
      it 'has the right phases' do
        expect(@content).to include @covid_study.phase.try(:split, '/').try(:join, '|')
      end
      it 'has the right enrollment' do
        expect(@content).to include @covid_study.enrollment
      end
      it 'has the right brief summary' do
        expect(@content).to include @covid_study.brief_summary.try(:description)
      end
      it 'has the right detailed_description' do
        expect(@content).to include @covid_study.detailed_description.try(:description)
      end
      it 'has the right conditions' do
        expect(@content).to include @covid_study.conditions.pluck(:name).join('|')
      end
      it 'has the right keywords' do
        expect(@content).to include @covid_study.keywords.pluck(:name).join('|')
      end
      it 'has the right interventions' do
        interventions = @covid_study.interventions
        intervention_name_type = []
        intervention_details = []
        interventions.each do |intervention| 
          intervention_name_type << "#{intervention.intervention_type || 'N/A'}: #{intervention.name}"
          intervention_details << "#{intervention.intervention_type || 'N/A'}:#{intervention.name}:#{intervention.description}"
        end
        intervention_name_type = intervention_name_type.join('|')
        intervention_details = intervention_details.join('|')

        expect(@content).to include(intervention_name_type, intervention_details)
      end
      it 'has the right arm details' do
        design_groups = @covid_study.design_groups
        arm_details = []
        arm_intervention_details = []
        design_groups.each do |design_group| 
          arm_details << "#{design_group.group_type || 'N/A'}:#{design_group.title}:#{design_group.description}"
          interventions = design_group.interventions
          interventions.each do |intervention|
            arm_intervention_details << "#{design_group.group_type || 'N/A'}[#{design_group.title}]:#{intervention.intervention_type}[#{intervention.name}]"
          end
        end
        arm_details = arm_details.join('|')
        arm_intervention_details = arm_intervention_details.join('|')

        expect(@content).to include(arm_details, arm_intervention_details)
      end
      it 'has the right outcome measures' do
        expect(@content).to include @covid_study.design_outcomes.pluck(:measure).join('|')
      end
      it 'has the right dates' do
        expect(@content).to include(
                                    @covid_study.start_date,
                                    @covid_study.primary_completion_date, 
                                    @covid_study.completion_date, 
                                    @covid_study.study_first_posted_date,
                                    @covid_study.results_first_posted_date,
                                    @covid_study.last_update_posted_date,
                                    @covid_study.nlm_download_date_description,
                                    @covid_study.study_first_submitted_date
                                   )
      end
      it 'has the right locations and facilities information' do
        facilities = @covid_study.facilities
        us_facility = facilities.find_by(country: ['USA', 'US', 'United States of America', 'United States', 'America'])
        expect(@content).to include(
                                    SearchResult.locations(facilities), 
                                    facilities.count
                                   )
      end
      it 'has the right study_design' do
        design = @covid_study.design
        expect(@content).to include(
                                    SearchResult.study_design(design),
                                    @covid_study.number_of_arms,
                                    @covid_study.number_of_groups,
                                    design.primary_purpose,
                                    design.intervention_model,
                                    design.observational_model,
                                    design.allocation,
                                    design.masking
                                  )
      end
      it 'has the right eligibility information' do
        eligibility = @covid_study.eligibility
        expect(@content).to include(
                                    eligibility.minimum_age,
                                    eligibility.maximum_age,
                                    eligibility.gender,
                                    eligibility.gender_description,
                                    eligibility.population,
                                    eligibility.criteria
                                  )
      end
      it 'has the right study documents' do
        expect(@content).to include SearchResult.study_documents(@covid_study)
      end
    end
    describe ':excel_column_names' do
      it 'has the right column names' do
        columns =  %w[
          nct_id
          title
          acronym
          other_ids
          url
          status
          why_stopped
          hcq
          has_dmc
          funded_bys
          sponsor_collaborators
          lead_sponsor
          collaborators
          study_type
          phases
          enrollment
          brief_summary
          detailed_description
          conditions
          keywords
          interventions
          intervention_details
          arm_details
          arm_intervention_details
          outcome_measures
          start_date
          primary_completion_date
          completion_date 
          first_posted
          results_first_posted
          last_update_posted
          nlm_download_date
          study_first_submitted_date
          has_expanded_access
          is_fda_regulated_drug
          is_fda_regulated_device
          is_unapproved_device
          locations
          number_of_facilities
          has_us_facility
          has_single_facility
          study_design
          number_of_arms
          number_of_groups
          primary_purpose
          intervention_model
          observational_model
          allocation
          masking
          subject_masked
          caregiver_masked
          investigator_masked
          outcomes_assessor_masked
          adaptive_protocol
          master_protocol
          platform_protocol
          umbrella_protocol
          basket_protocol
          minimum_agey
          maximum_agey
          gender
          gender_based
          gender_description
          healthy_volunteers
          population
          criteria
          study_results
          study_documents
        ]
        expect(SearchResult.excel_column_names).to eq columns
      end
      it 'has the right number of columns' do
        expect(SearchResult.excel_column_names.count).to eq 68
      end
    end
    describe ':save_xlsx' do
    end
    describe ':hcq_query' do
    end
    describe ':locations' do
    end
    describe ':study_design' do
    end
    describe ':single_term_query' do
    end
    describe ':study_documents' do
    end
  end
end
