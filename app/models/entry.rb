class Entry < ApplicationRecord
  belongs_to :feed

  validates :entry_id, presence: true
end