# config valid for current version and patch releases of Capistrano
lock '~> 3.19.2'

# Load environment variables from .env file (optional)
require 'dotenv'
Dotenv.load

set :application, 'the_cover_letter_ai'
set :repo_url, 'https://github.com/zilton7/ai-cover-letter.git'
set :git_http_username, 'zilton7'
set :git_http_password, ENV['GITHUB_ACCESS_TOKEN']

set :branch, 'development'

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

set :rails_env, 'production'
set :rbenv_type, :user
set :rbenv_ruby, '3.4.1'

set :linked_files, fetch(:linked_files, [])
  .push('config/database.yml', 'config/credentials/production.yml.enc')

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'vendor/bundle', '.bundle', 'public/system', 'public/uploads',
       'storage'

set :assets_roles, %i[web app]

# Only keep the last 5 releases to save disk space
set :keep_releases, 5

# Default value for :format is :airbrussh.
# You can configure the Airbrussh format using :format_options.
set :format, :airbrussh
set :format_options, command_output: true, log_file: 'log/capistrano.log',
                     color: :auto, truncate: :auto

# Sidekiq settings
set :sidekiq_roles, :app
set :sidekiq_config_files, %w[sidekiq.yml]
# set :sidekiq_config, -> { "#{current_path}/config/sidekiq.yml" }
set :sidekiq_processes, 2

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
