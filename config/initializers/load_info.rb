APP_INFO = YAML.load_file(Rails.root.join('config', 'info', 'app.yml'), aliases: true)[Rails.env].deep_symbolize_keys
