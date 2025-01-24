module TestHelper
  ActiveSupport.on_load(:action_mailer) do
    Rails.application.reload_routes_unless_loaded
  end
end
