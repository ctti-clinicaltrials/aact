module FormHelpers
  def submit
    find('input[name="commit"]').click
  end
end
