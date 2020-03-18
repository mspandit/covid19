class Author < ApplicationRecord
  has_many :authorships
  
  def full_name
    self.suffix.blank? ? "#{self.first} #{self.middle} #{self.last}" : "#{self.first} #{self.middle} #{self.last}, #{self.suffix}"
  end
end
