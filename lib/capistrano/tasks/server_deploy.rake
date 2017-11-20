task :server_deploy do
  on "ctti-aact@ctti-web-dev-01.oit.duke.edu" do
    execute "~/server_deploy"
  end
end

