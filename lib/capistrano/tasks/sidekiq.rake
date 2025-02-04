namespace :sidekiq do
  task :restart do
    invoke 'sidekiq:stop'
    invoke 'sidekiq:start'
  end

  after 'deploy:finished', 'sidekiq:restart'

  task :stop do
    on roles(:app) do
      within current_path do
        # Use `pgrep` to find the Sidekiq process ID
        pid = capture("pgrep -f 'sidekiq'")

        if pid.empty?
          info 'No Sidekiq process found'
        else
          info "Stopping Sidekiq process #{pid}"
          execute :kill, "-TERM #{pid}"
          # Optionally, wait for the process to stop
          execute :sleep, '5'
        end
      end
    rescue SSHKit::Command::Failed => e
      warn "Failed to stop Sidekiq: #{e.message}"
    end
  end

  task :start do
    on roles(:app) do
      within current_path do
        execute "nohup bundle exec sidekiq -e #{fetch(:stage)} -C config/sidekiq.yml > /dev/null 2>&1 &"
      end
    end
  end
end
