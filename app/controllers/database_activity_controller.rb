class DatabaseActivityController < ApplicationController
  before_action :authenticate_user, only: [:show]

  def index
    @activities=[]
    DatabaseActivity.all.each{|row|
      @activities << row if !filtered?(params) or passes_filter?(row,params)
    }
    render json: @activities, root: false
  end

  def show
    @activities=DatabaseActivity.all
  end

  def filtered?(params)
    searchable_attribs.each{|attrib| return true if !params[attrib].blank? }
    return false
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

  def passes_filter?(row,params)
    filters(params).each{|filter|
      key=filter.keys.first
      val=filter.values.first
      return false if row[key].nil?
      return false if !row[key].try(:downcase).include?(val.try(:downcase))
    }
    return true
  end

  def searchable_attribs
    ['id', 'ip_address', 'file_name', 'description']
  end

  def authenticate_user
    if !params['pwd'] or (params['pwd'] != ENV["AACT_VIEW_PASSWORD"])
      render plain: "Only accessible to authorized folks."
    end
  end

end
