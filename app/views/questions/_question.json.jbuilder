json.extract! question, :id, :content, :count, :created_at, :updated_at
json.url question_url(question, format: :json)
