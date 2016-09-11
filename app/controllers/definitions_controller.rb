class DefinitionsController < ApplicationController

  # *******///********
  # To update this info, replace the spreadsheet on the AWS server and ensure column names
  # on lines 10-18 match those in the spreadsheet.
  # *******///********

  @results_url=ClinicalTrials::FileManager.nlm_results_data_url
  @protocol_url=ClinicalTrials::FileManager.nlm_protocol_data_url

  def index
    data = Roo::Spreadsheet.open(ClinicalTrials::FileManager.data_dictionary)
    dataOut = []
    header = data.first
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        fix_attribs(row)
        dataOut << row
      end
    end
    render json: dataOut, root: false
  end

  def fix_attribs(hash)
    hash["xml source"].html_safe if hash["xml source"]

    if hash["nlm documentation"].present?
      hash["db section"].downcase == "results" ? url=@results_url : url=@protocol_url
      hash["nlm documentation"] = "<a href='#{url}'#"+hash["nlm documentation"]+'" target="_blank">'+'NLM Info'+'</a>'
    end
  end

end
