class DefinitionsController < ApplicationController\

  def index

    # *******///********
    # TO UPDATE THE DATA IN THIS DICTIONARY DICTIONARY, REPLACE THIS SPREADSHEET AND MAKE SURE THE COLUMN NAMES ON LINES 10-18 MATCH THOSE IN THE SPREADSHEET
    # *******///********

    # Retrieve dictionary.xlsx from public folder
    dictionary = Roo::Spreadsheet.open('./public/dictionary.xlsx')

    dataResult = []

    dictionary.sheet(0).each({'Table Name' => 'Table Name',
                              'Column Name' => 'Variable Name',
                              'Data Type' => 'DATA TYPE',
                              'NLM Description' => 'NLM Definitions',
                              'Comments' => 'CTTI Notes',
                              'NLM Req' => 'NLM Required',
                              'FDAAA Req' => 'FDAAA Required',
                              'Max Length Used' => 'MAX LENGTH UTILIZED',
                              'PRS Label' => 'Variable Label'}) do |hash|
      dataResult << hash

    end

    # Take the column names out of the resulting array
    dataResult.shift


    # Filtering
    params.each do |key, value|
      puts key

      if value.present? && key != "action" && key != "controller"
        puts "#***********************************#"
        puts key
        puts value
        puts "#***********************************#"

        dataResult = dataResult.select do |hash|
          # hash["Table Name"] == params["Table Name"]
          require 'string/similarity'

          String::Similarity.cosine(hash[key].downcase, value.downcase) > 0.6

        end


      end
    end

    # Return an array of objects as JSON that has the root key removed
    render json: dataResult, root: false
  end
end
