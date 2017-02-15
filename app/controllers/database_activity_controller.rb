class DatabaseActivityController < ApplicationController

  def index
    @activities=DatabaseActivity.all
    puts "============================"
    puts "DatabaseActivityController.index"
    puts "============================"
    render json: @activities, root: false
  end

  def show
    @activities=DatabaseActivity.all
    puts "============================"
    puts "DatabaseActivityController.show"
    puts "============================"
    #render json: @activities, root: false
  end

end
