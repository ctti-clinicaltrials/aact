class PagesController < ApplicationController
  def home
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
  end

  def snapshots
    @files=Util::FileManager.snapshot_files
    @most_recent=@files.last
  end

  def pipe_files
    @files=Util::FileManager.pipe_delimited_files
    @most_recent=@files.last
  end

  def points_to_consider
    @admin_schema_diagram=Util::FileManager.admin_schema_diagram
    @schema_diagram=Util::FileManager.schema_diagram
    @data_dictionary=Util::FileManager.data_dictionary
    @table_dictionary=Util::FileManager.table_dictionary
  end

  def learn_more
    @admin_schema_diagram=Util::FileManager.admin_schema_diagram
    @schema_diagram=Util::FileManager.schema_diagram
    @data_dictionary=Util::FileManager.data_dictionary
    @table_dictionary=Util::FileManager.table_dictionary
  end

  def schema
    @admin_schema_diagram=Util::FileManager.admin_schema_diagram
    @schema_diagram=Util::FileManager.schema_diagram
    @data_dictionary=Util::FileManager.data_dictionary
    @table_dictionary=Util::FileManager.table_dictionary
    @show_dictionary_link = true
  end

  def sanity_check
    @sanity_check_report = Admin::SanityCheck.last.report
  end

  def letsencrypt
     render text: "ze3b2B0EROvY0-pxWJO9va4MrihcnDgpHQfZskEts4o.h4AET8S0L96XTM6tGuJQBD60-2rHKzZ4mlYzKl9Ay6A"
  end

end
