json.extract! author, :id, :first, :middle, :last, :suffix, :laboratory, :institution, :addr_line, :post_code, :settlement, :country, :created_at, :updated_at
json.url author_url(author, format: :json)
