namespace :whenever do
  task :update_cron do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec,
                "whenever --update-crontab #{fetch(:whenever_identifier)} --set 'environment=#{fetch(:rails_env)}&path=#{release_path.parent}/current'"
      end
    end
  end

  task :clear_cron do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec, "whenever --clear-crontab #{fetch(:whenever_identifier)}"
      end
    end
  end
end
