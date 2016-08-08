class DefinitionsController < ApplicationController\

  def index
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

    dataResult.shift

    if params["Table Name"].present?
      dataResult = dataResult.select do |hash|
        hash["Table Name"] == params["Table Name"]
      end

    end

    # filtering

    render json: dataResult, root: false
  end
end
