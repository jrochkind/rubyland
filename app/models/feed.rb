class Feed < ApplicationRecord
  has_many :entries, dependent: :destroy

  validates_presence_of :feed_url
end