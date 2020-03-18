class Paper < ApplicationRecord
  has_many :authorships
  has_many :body_texts
  
  def self.search(terms="")
    sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/, "+")])
    Paper.where("search_vector @@ #{sanitized}")
  end
end
