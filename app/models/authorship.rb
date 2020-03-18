class Authorship < ApplicationRecord
  belongs_to :paper
  belongs_to :author
end
