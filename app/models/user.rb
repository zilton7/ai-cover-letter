class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :jobs, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :email, presence: true

  def self.from_google(u)
    create_with(uid: u[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
  end

  def admin?
    email.in? ['zilasino27@gmail.com', 'kps-17@hotmail.com']
  end

  def subscription
    subscriptions.last
  end

  def subscribed?
    subscription&.status == 'active'
  end

  def credits_count
    return "\u{221E}" if subscribed?

    credits
  end

  def deduct_credit!
    return if subscribed? || credits.zero?

    credits = self.credits -= 1
    update(credits:)

    broadcast_update_to 'credits',
                        target: "credits_for_user_#{id}",
                        html: "<p class=\"text-sm\">Credits: <span class=\"font-bold text-[#019863af]\">#{credits}</span></p>"
  end
end
