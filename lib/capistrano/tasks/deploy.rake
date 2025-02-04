namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'sidekiq:restart'
  end

  after :publishing, :restart
  after :finishing, 'deploy:cleanup'
end
