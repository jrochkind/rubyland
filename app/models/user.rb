class User < ApplicationRecord
  include Clearance::User

  validates_length_of :password, minimum: 8, except: -> { skip_password_validation? }

  def admin?
    role == "admin"
  end
end
