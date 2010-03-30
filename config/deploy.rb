default_run_options[:pty] = true
set :application, "tweetsworth" # The name of the application
set :repository,  "git@github.com:adriand/Tweetsworth.git" # Path to the Git Repo
set :scm, "git"
set :scm_passphrase, "9shwartz90005"
set :user, "deploy"
set :deploy_via, :remote_cache

set :deploy_to, "/var/apps/#{application}"

role :app, "app1.factore.ca", "app2.factore.ca"
role :db, "app1.factore.ca", :primary => true

before("deploy:cleanup") { set :user, "root" }
# after("deploy:update_code") { run "cd #{current_release}; cp config/database.yml.template config/database.yml" }
# after("deploy:restart") { run "ln -s /var/apps/tweetsworth/shared/.htaccess /var/apps/tweetsworth/current/public/.htaccess" }

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end