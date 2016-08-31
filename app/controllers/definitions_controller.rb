class DefinitionsController < ApplicationController\

  def index

    # *******///********
    # TO UPDATE THE DATA IN THIS DICTIONARY DICTIONARY, REPLACE THIS SPREADSHEET AND MAKE SURE THE COLUMN NAMES ON LINES 10-18 MATCH THOSE IN THE SPREADSHEET
    # *******///********

    # Retrieve dictionary.xlsx from public folder
    dictionary = Roo::Spreadsheet.open('./public/dictionary.xlsx')

    dataResult = []

    dictionary.sheet(0).each({'Table Section' => 'table section',
                              'Table Name' => 'table',
                              'Column Name' => 'column',
                              'AACT Contribution' => 'AACT contribution',
                              'XML Source' => 'xml source',
                              'NLM Documentation' => 'nlm documentation',
                              'AACT1 Variable' => 'AACT1 Variable',
                              'PRS Label' => 'PRS Label',
                              'CTTI Note' => 'CTTI Note',
                              'Data Type' => 'Data Type',
                              '# of rows in table' => 'number of rows in table',
                              'Distinct Column Values' => 'distinct values in column',
                              'Max Length Allowed' => 'max length allowed',
                              'Max Length Current' => 'max length current',
                              'Min Length Current' => 'min length current',
                              'Avg. Length Current' => 'average length current',
                              'Common Values' => 'common values',
                              'NLM Required' => 'nlm requred',
                              'FDAAA Required' => 'fdaaa required'}) do |hash|

      if hash["XML Source"]
        hash["XML Source"].html_safe

      end

      if hash["NLM Documentation"].present?
        hash["NLM Documentation"] = '<a href=" https://prsinfo.clinicaltrials.gov/definitions.html#'+hash["NLM Documentation"]+'" target="_blank">'+hash["NLM Documentation"]+'</a>'

      end

      unless hash["Table Name"] == "table"

        begin
          table = hash["Table Name"].sub(/_/, "").singularize.try(:constantize)
          hash["# of rows in table"] = table.count
        rescue NameError
          hash["# of rows in table"] = "N/A"
        end

      end

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

          if hash[key].nil? || value.nil?
            0.0
          else
            String::Similarity.cosine(hash[key].try(:downcase), value.try(:downcase)) > 0.7
          end



        end


      end
    end

    # Return an array of objects as JSON that has the root key removed
    render json: dataResult, root: false
  end
end
