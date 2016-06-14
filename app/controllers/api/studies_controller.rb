module Api
  class StudiesController < ApplicationController
    def show
      @study = Study.find_by(nct_id: params[:nct_id])
      @related_records = params[:with_related_records]

      render 'show.json.jbuilder'
    end
  end
end
