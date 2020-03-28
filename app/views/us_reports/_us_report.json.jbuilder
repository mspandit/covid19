json.extract! us_report, :id, :county, :state, :cases, :deaths, :created_at, :updated_at
json.url us_report_url(us_report, format: :json)
