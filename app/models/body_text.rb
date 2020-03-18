class BodyText < ApplicationRecord
  belongs_to :paper
  
  def self.search(terms="")
    sanitized = sanitize_sql_array(["to_tsquery('english', ?)", terms.gsub(/\s/, "+")])
    BodyText.where("search_vector @@ #{sanitized}")
  end
end
