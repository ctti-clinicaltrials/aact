class ChartsController < ApplicationController
  before_action :set_chart, only: [:show, :edit, :update, :destroy]

  # GET /charts
  # GET /charts.json
  def index
    gon.since_date=(Date.today - 2.years).to_s
    study_types=Study.completed_since(gon.since_date).collect{|s|s.study_type}.flatten
    study_phases=Study.completed_since(gon.since_date).collect{|s|s.phase}.flatten
    count_hash = Hash.new(0)
    study_types.each{|x|count_hash[x] += 1 if x}
    gon.type_counts=@type_count=count_hash.collect{|k,v| [k,v] if k }

    count_hash = Hash.new(0)
    study_phases.each{|x|count_hash[x] += 1 if x}
    gon.phase_counts=@phase_count=count_hash.collect{|k,v| [k,v] if k }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_chart
    sponsors=Study.all[0..20].collect{|s|s.sponsors}.flatten
    agencies=sponsors.collect{|a| a.name}
    count_hash = Hash.new(0)
    agencies.each{|agency|count_hash[agency] += 1 if agency}
    gon.sponsor_count=@sponsor_count=count_hash.collect{|k,v| [k,v] if k }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chart_params
    params[:chart]
  end
end
