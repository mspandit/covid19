# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'
require 'json'
require 'faraday'
require 'tqdm'

ROOT_DIR = '../COVID-19/csse_covid_19_data/csse_covid_19_time_series/'
ROOT_URL = "development" == ENV['RAILS_ENV'] ? "http://localhost:3000/" : "http://www.know-covid19.info/"

if ENV["SECRET"].nil? || ENV["SECRET"].empty?
  puts("Set SECRET environment variable. Exiting...")
  exit 1
else
  SECRET = ENV["SECRET"]
end

def process(time_series_file, db_field)
  data = []
  CSV.parse(open(Dir[ROOT_DIR + time_series_file].first).read, headers: true).tqdm.each do |row|
    region_id = JSON.parse(
      Faraday.post(
        "#{ROOT_URL}regions/#{SECRET}.json",
        "region[province]": row['Province/State'],
        "region[country]": row['Country/Region'],
        "region[latitude]": row['Lat'],
        "region[longitude]": row['Long']
      ).body
    )['id']
    (row.fields.length - 1..row.fields.length - 1).each do |column_index|
      created_at = DateTime.strptime(row.headers[column_index], "%m/%d/%y")
      data.append({
        region_id: region_id,
        created_at: created_at,
        db_field => row.field(column_index)
      })
    end
  end
  Faraday.post(
    "#{ROOT_URL}reports/#{SECRET}.json",
    data: data.to_json
  )
end

process('time_series_covid19_deaths_global.csv', 'deaths')
process('time_series_covid19_confirmed_global.csv', 'confirmed')