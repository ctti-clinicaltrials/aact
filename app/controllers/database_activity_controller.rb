class DatabaseActivityController < ApplicationController

  def index
    @activities=DatabaseActivity.all
  end

  def show
    @activity = DatabaseActivity.find(params['id'])
  end

end
