module StudyCountsByYearDoc
  extend BaseDoc

  api :GET, '/studies/counts_by_year', 'Show study counts by year'
  example 'derp'
  def index
  end
end
