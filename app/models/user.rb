class User < ApplicationRecord
  include Clearance::User

  def admin?
    role == "admin"
  end
end
