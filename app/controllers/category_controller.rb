class CategoryController < ApplicationController

  def show
    @categories=Support::Category.categories
    @category=Support::Category.new
  end

  def get_studies
    begin
      mesh_terms = Support::MeshTerm.for_category(params[:id]).pluck(:term).uniq
      free_text_terms = Support::FreeTextTerm.for_category(params[:id]).pluck(:term).uniq
      nct_ids=[]
      mesh_terms.each_slice(70) {|terms|
        nct_ids << BrowseCondition.where(:mesh_term => terms).pluck(:nct_id).uniq
        nct_ids << BrowseCondition.all.pluck(:nct_id).uniq
        nct_ids << BrowseIntervention.where(:mesh_term => terms).pluck(:nct_id).uniq
      }
      free_text_terms.each_slice(70) {|terms|
        nct_ids << BrowseCondition.where(:mesh_term => terms).pluck(:nct_id).uniq
        nct_ids << Keyword.where(:name => terms).pluck(:nct_id).uniq
      }
      studies=[]
      nct_ids.flatten.uniq.each_slice(70) {|ids|
        study_batch = Study.where(:nct_id => ids).pluck(:nct_id, :brief_title, :study_type, :start_date, :primary_completion_date)
        studies << study_batch.uniq.sort.map{|nct_id, brief_title, study_type, start_date, primary_completion_date|
          {'nct_id' => nct_id,
           'title' => brief_title,
           'type' => study_type,
           'start' => start_date,
           'end' => primary_completion_date } }
      }
      @studies = studies.flatten.uniq
      @studies << {:brief_title => 'No studies found'} if @studies.empty?
      render :json => @studies
    rescue
      render :json => {'term' => 'None'}.to_json
    end
  end

  def get_terms
    begin
      mesh_terms = Support::MeshTerm.term_list_for_category(params[:id])
      free_text_terms = Support::FreeTextTerm.term_list_for_category(params[:id])
      @terms=[]
      (mesh_terms + free_text_terms).flatten.each {|term|
        @terms << term if !filtered?(params) or passes_filter?(term,params)
      }
      render :json => @terms
    rescue
      render :json => {'term' => 'None'}.to_json
    end
  end

  def filtered?(params)
    searchable_attribs.each{|attrib| return true if !params[attrib].blank? }
    return false
  end

  def passes_filter?(term,params)
    filters(params).each{|filter|
      key=filter.keys.first
      val=filter.values.first
      return false if term[key].nil?
      return false if !term[key].try(:downcase).include?(val.try(:downcase))
    }
    return true
  end

  def filters(params)
    col=[]
    searchable_attribs.each{|attrib|
      if !params[attrib].blank?
        filter = {attrib=>params[attrib]}
        col << filter
      end
    }
    col
  end

  def searchable_attribs
    ['term', 'type', 'identifiers', 'tite', 'start', 'end']
  end
end
