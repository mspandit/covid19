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

ROOT_DIR = '../covid-19-data/'
ROOT_URL = "development" == ENV['RAILS_ENV'] ? "http://localhost:3000/" : "http://www.know-covid19.info/"

if ENV["SECRET"].nil? || ENV["SECRET"].empty?
  puts("Set SECRET environment variable. Exiting...")
  exit 1
else
  SECRET = ENV["SECRET"]
end

def process(states_file, counties_file)
  data = []
  CSV.parse(open(Dir[ROOT_DIR + states_file].first).read, headers: true).tqdm.each do |row|
    data.append({
      created_at: DateTime.strptime(row['date'], "%Y-%m-%d"),
      state: row['state'],
      cases: row['cases'],
      deaths: row['deaths']
    })
  end
  Faraday.post("#{ROOT_URL}us_reports/#{SECRET}.json") do |req|
    req.options.timeout = 600
    req.body = "data=#{data.to_json}"
  end
end

process('us-states.csv', 'us-counties.csv')
