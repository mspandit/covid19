# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'
require 'faraday'
require 'digest'

ROOT_DIRS = ['public/comm_use_subset']
ROOT_URL = "development" == ENV['RAILS_ENV'] ? "http://localhost:3000/" : "http://cord19.herokuapp.com/"

if ENV["SECRET"].nil? || ENV["SECRET"].empty?
  puts("Set SECRET environment variable. Exiting...")
  exit 1
else
  SECRET = ENV["SECRET"]
end

ROOT_DIRS.each do |root_dir|
  Dir[root_dir + "/*.json"].each do |filename|
    open(filename) do |f|
      json = JSON.parse(f.read)
      abstract = json['abstract'].inject([]) { |texts, text| texts << text['text'] }.join("\n\n")
      paper_id = JSON.parse(
        Faraday.post(
          "#{ROOT_URL}papers/#{SECRET}.json", 
          "paper[paper_id]": json['paper_id'], 
          "paper[title]": json['metadata']['title'], 
          "paper[abstract]": abstract
        ).body
      )['id']
      json['metadata']['authors'].each do |author|
        Faraday.post(
          "#{ROOT_URL}authors/#{SECRET}.json",
          "author[paper_id]": paper_id,
          "author[first]": author['first'],
          "author[middle]": author['middle'].join(' '),
          "author[last]": author['last'],
          "author[suffix]": author['suffix'],
          "author[laboratory]": author['laboratory'],
          "author[institution]": author['institution'],
          "author[addr_line]": author['addrLine'],
          "author[post_code]": author['postCode'],
          "author[settlement]": author['settlement'],
          "author[country]": author['country']
        )
      end
      json['body_text'].each_with_index do |bt, index|
        Faraday.post(
          "#{ROOT_URL}body_texts/#{SECRET}.json",
          "body_text[paper_id]": paper_id,
          "body_text[sequence]": index,
          "body_text[content]": bt['text']
        )
      end
      print "."
      $stdout.flush
    end
  end
end
