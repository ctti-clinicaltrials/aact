class DefinitionsController < ApplicationController\

  def index
    dictionary = Roo::Spreadsheet.open('./public/dictionary.xlsx')
    # xlsx = Roo::Excelx.new("./new_prices.xlsx")

    # # Use the extension option if the extension is ambiguous.
    # xlsx = Roo::Spreadsheet.open('./rails_temp_upload', extension: :xlsx)
    #
    # xlsx.info

    # dataResult = dictionary.sheet(0).row(5)

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
      puts hash.inspect
      # => { id: 1, name: 'John Smith' }
      dataResult << hash

    end

    dataResult.shift

    # filtering

    render json: dataResult, root: false
  end
end
