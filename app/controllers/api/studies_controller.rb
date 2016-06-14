module Api
  class StudiesController < ApplicationController
    def show
      @study = Study.find_by(nct_id: params[:nct_id])
      @related_records = params[:with_related_records]

      if @study.present?
        render 'show.json.jbuilder'
      else
        render json: 'Study not found', status: 404
      end
    end
  end
end
