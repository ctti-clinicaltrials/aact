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

      render json: @studies
    end

  end
end
