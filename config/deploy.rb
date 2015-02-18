require 'bundler/capistrano'

server 'mousedata.link', :web, :app, :db, primary: true

set :application, 'arbeit'
set :user, 'sdeploy'
set :group, 'admin'
set :deploy_to, "/home/#{user}/apps/#{application}"

set :scm, 'git'
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :repository, "https://github.com/skylarweaver/Arbeit_2014.git"
set :branch, 'master'

set :use_sudo, false

set :stages, ["staging", "production"]
set :default_stage, "production"

# share public/uploads
set :shared_children, shared_children + %w{public/uploads}

# allow password prompt
default_run_options[:pty] = true

# turn on key forwarding
ssh_options[:forward_agent] = true

# keep only the last 5 releases
after 'deploy', 'deploy:cleanup'
after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_shared do
    run "ln -s /home/sdeploy/apps/arbeit/shared/settings.yml /home/sdeploy/apps/arbeit/releases/#{release_name}/config/"
  end
end

before "deploy:assets:precompile", "deploy:symlink_shared"
after "deploy:symlink_shared", "deploy:migrate"

#Steps
#uncomment stuff above
#add settings to git ignore
#ftp settings file to server in this: /home/deploy/apps/arbeit/shared/settings.yml 
#Check out deploy branch to copy stuff from there
#setttings won't be in git repsository so we will be storing it on the server securely (unless they are logged in, tthey won't see). Could even  use SFTP, securer*
