class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :generate_authentication_token!
  after_initialize :set_defaults

  validates :auth_token, uniqueness: true
  validates :role, presence: true

  has_one :organization
  has_one :setting, autosave: true, dependent: :destroy

  before_save { self.email = email.downcase }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # User should have a role_id, although we may want to look into setting
  # Up seperate classes.
  belongs_to :role

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def set_defaults
    unless role
      # Set the default role as other until a role is passed in.
        # Also, need to set the "Type"
      self.role = Role.find(2)
    end
    set_default_settings
  end

  def set_default_settings
    unless setting
      if self.role_id == 0
        self.setting = Setting.create(active: true, notifications: false)
      else
        self.setting = Setting.create(active: false, notifications: false)
      end
    end
  end

end
