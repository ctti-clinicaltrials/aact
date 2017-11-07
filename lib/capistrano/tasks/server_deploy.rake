task :server_deploy do
  on "tibbs001@ctti-web-dev-01.oit.duke.edu" do
    execute "~/server_deploy"
  end
end


# The server-side script exists to do all the work on the server rather than ssh from the client for each command.
# When we ssh for each command, the MFA confirmation pops up for each command.  By running this script, we avoid having
# to do an MFA confirm a dozen times throughout the deploy.
#
# Below is the content of /home/tibbs001/server_deploy on ctti-web-dev-01

#release_dir=`date +%Y%m%d%H%M%S`
#mkdir -p /tmp
#chmod 700 /tmp/git-ssh-aact-development-tibbs001.sh
#git ls-remote git@github.com:ctti-clinicaltrials/aact.git HEAD >> REVISION
#mkdir -p /srv/ctti/www/aact/shared /srv/ctti/www/aact/releases
#mkdir -p /srv/ctti/www/aact/shared/public/assets
#mkdir -p /srv/ctti/www/aact/releases/${release_dir}
#rm -rf aact
#git clone git@github.com:ctti-clinicaltrials/aact.git; cd ~/aact; git checkout development
#cd ~/aact; git remote set-url origin git@github.com:ctti-clinicaltrials/aact.git; git remote update --prune
#cd ~/aact; git archive development | /usr/bin/env tar -x -f - -C /srv/ctti/www/aact/releases/${release_dir}
#mkdir -p /srv/ctti/www/aact/releases/${release_dir}/public
#ln -s /srv/ctti/www/aact/shared/public/assets /srv/ctti/www/aact/releases/${release_dir}/public/assets
#cd /srv/ctti/www/aact/releases/${release_dir}; gem install bundler
#cd /srv/ctti/www/aact/releases/${release_dir}; bundle install --path /srv/ctti/www/aact/shared/bundle #--quiet
#ln -s /srv/ctti/www/aact/current /srv/ctti/www/aact/releases/${release_dir}


