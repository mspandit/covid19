json.extract! body_text, :id, :content, :search_vector, :created_at, :updated_at
json.url body_text_url(body_text, format: :json)
