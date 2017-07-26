class TableExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'table_export'

  def perform(delimiter)
    Util::TableExporter.new.run(delimiter: delimiter, should_archive: true)
  end
end
