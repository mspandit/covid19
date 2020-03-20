json.extract! report, :id, :region_id, :confirmed, :deaths, :recovered, :created_at, :updated_at
json.url report_url(report, format: :json)
