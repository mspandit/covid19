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

ROOT_DIRS = ['../COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/']
ROOT_URL = "development" == ENV['RAILS_ENV'] ? "http://localhost:3000/" : "http://cord19.herokuapp.com/"

if ENV["SECRET"].nil? || ENV["SECRET"].empty?
  puts("Set SECRET environment variable. Exiting...")
  exit 1
else
  SECRET = ENV["SECRET"]
end

def safe_col(row, header, field)
  row.headers.include?(header) ? row.fetch(header) : row.field(field)
end

ROOT_DIRS.each do |root_dir|
  Dir[root_dir + "/*.csv"].each do |filename|
    open(filename) do |f|
      CSV.parse(f.read, headers: true) do |row|
        region_id = JSON.parse(
          Faraday.post(
            "#{ROOT_URL}regions/#{SECRET}.json",
            "region[province]": safe_col(row, "Province/State", 0),
            "region[country]": safe_col(row, "Country/Region", 1),
            "region[latitude]": safe_col(row, "Latitude", 6),
            "region[longitude]": safe_col(row, "Longitude", 7)
          ).body
        )['id']
        created_at = begin
          DateTime.parse(safe_col(row, "Last Update", 2))
        rescue ArgumentError => e
          dt = DateTime.strptime(safe_col(row, "Last Update", 2), "%m/%d/%Y %H:%M") 
          if dt.year < 2020
            dt = DateTime.strptime(safe_col(row, "Last Update", 2), "%m/%d/%y %H:%M")
          end
          dt
        end
        
        Faraday.post(
          "#{ROOT_URL}reports/#{SECRET}.json",
          "report[region_id]": region_id,
          "report[created_at]": created_at,
          "report[confirmed]": safe_col(row, "Confirmed", 3),
          "report[deaths]": safe_col(row, "Deaths", 4),
          "report[recovered]": safe_col(row, "Recovered", 5)
        )
        print "."
        $stdout.flush
      end
    end
  end
end
