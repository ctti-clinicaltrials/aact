class DefinitionsController < ApplicationController

  # *******///********
  # This code uses data dictionary spreadsheet on the AWS server
  # *******///********

  @@results_url=ClinicalTrials::FileManager.nlm_results_data_url
  @@protocol_url=ClinicalTrials::FileManager.nlm_protocol_data_url

  def index
    data = Roo::Spreadsheet.open(ClinicalTrials::FileManager.data_dictionary)
    header = data.first
    dataOut = []
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        if !filtered?(params) or passes_filter?(row,params)
          dataOut << fix_attribs(row)
        end
      end
    end
    render json: dataOut, root: false
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

  def fix_attribs(hash)
    if hash['source']
      fixed_content=hash['source'].gsub(/\u003c/, "&lt;").gsub(/>/, "&gt;")
      hash['source']=fixed_content
    end

    if hash['enumerations']
      stime=Time.now
      results=ActiveRecord::Base.connection.execute("SELECT DISTINCT #{hash['column']}, COUNT(*) AS cnt FROM #{hash['table']} GROUP BY #{hash['column']} ORDER BY cnt ASC")
      str="<table class='enumerations' >"
      cntr=results.ntuples - 1
      while cntr >= 0 do
        str=str+'<tr>'
        val=results.getvalue(cntr,0).to_s
        val='-null-' if val.size==0
        row_count=results.getvalue(cntr,1).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
        str=str+"<td class='enum-val'>" + val + " </td><td align='right'>"+row_count+"</td>"
        str=str+'</tr>'
        cntr=cntr-1
      end
      str=str+'</table>'
      puts "enums for #{hash['table']}.#{hash['column']}:  #{Time.now - stime}"
      hash['enumerations'] = str
    end

    if hash['nlm doc'].present?
      url=hash["db section"].downcase == "results" ? @@results_url : @@protocol_url
      hash['nlm doc'] = "<a href=#{url}##{hash['nlm doc']} class='navItem' target='_blank'><i class='fa fa-book'></i></a>"
    end

    if (hash['column'].downcase == 'id') or (hash['table'].downcase == 'studies' and hash['column'].downcase == 'nct_id')
      # If this is the table's primary key, display row count for the table.
      tab=hash['table'].downcase
      results=ActiveRecord::Base.connection.execute("SELECT row_count FROM sanity_checks WHERE table_name='#{tab}' AND most_current=true")
      if results.ntuples > 0
        row_count=results.getvalue(0,0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
        hash['row count']=row_count
      else
        hash['row count']=0
      end
      hash['table'] = "<span class='primary-key' id='#{tab}'>#{hash['table']}</span>"
    end

    return hash
  end

  def searchable_attribs
    ['db section', 'table', 'column', 'data type', 'xml source', 'source', 'CTTI note']
  end

end
