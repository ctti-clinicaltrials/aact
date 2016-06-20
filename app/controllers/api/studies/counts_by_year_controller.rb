module Api
  class Studies::CountsByYearController < ApplicationController
    include StudyCountsByYearDoc

    def index
      @counts = Study.all.group('extract(year from start_date) :: integer').count

      render json: @counts
    end
  end
end
