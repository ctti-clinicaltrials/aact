module Api
  class StudiesController < ApplicationController
    include StudiesDoc

    def show
      @study = Study.find_by(nct_id: params[:nct_id])
      @related_records = params[:with_related_records]

      if @study.present?
        render 'show.json.jbuilder'
      else
        render json: 'Study not found', status: 404
      end
    end

    def index
      @studies = Study.all

      paginate json: @studies, per_page: 500
    end

  end
end
