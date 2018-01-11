class DictionaryController < ApplicationController
  def show
    @admin_schema_diagram=Util::FileManager.admin_schema_diagram
    @schema_diagram=Util::FileManager.schema_diagram
    @data_dictionary=Util::FileManager.data_dictionary
    @table_dictionary=Util::FileManager.table_dictionary
    @tables = []
    tabs=get_dictionary
    header = tabs.first
    (2..tabs.last_row).each do |i|
      row = Hash[[header, tabs.row(i)].transpose]
      if !row['table'].nil?
        @tables << fix_attribs(row)
      end
    end
  end

  def get_dictionary
    Roo::Spreadsheet.open(Util::FileManager.new.backend_table_dictionary)
  end

  def fix_attribs(hash)
    # get row count from the Admin::DataDefinition.row_count
    tab=hash['table'].downcase
    col=(tab=='studies' ? 'nct_id' : 'id')
    results=Admin::AdminBase.connection.execute("SELECT row_count FROM data_definitions WHERE table_name='#{tab}' and column_name='#{col}'")
    if results.ntuples > 0
      row_count=results.getvalue(0,0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      hash['row count']=row_count
    else
      hash['row count']=0
    end
    hash['formatted_table'] = "<span id='#{tab}'>#{hash['table']}</span>"
    hash
  end

end
