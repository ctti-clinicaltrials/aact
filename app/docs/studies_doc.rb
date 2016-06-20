module StudiesDoc
  extend BaseDoc

  resource_description do
    resource_id 'Studies'
  end

  api :GET, '/studies/:nct_id', 'Show a specific study'
  param :nct_id, String, required: true
  def show
  end

  api :GET, '/studies', 'Show all studies'
  def index
  end

end
