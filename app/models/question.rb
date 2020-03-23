require 'net/http'

class Question < ApplicationRecord
  validates_presence_of :count
  validates_uniqueness_of :content

  def retrieve(uri)
    json_request = Net::HTTP::Post.new(uri.request_uri)
    json_request.body = "{ \"questions\": [\"#{self.content}\"] }"
    json_request['Content-Length'] = json_request.body.length
    json_request['Content-Type'] = 'application/json'
    body = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(json_request).body
    end
    if body.blank?
      {}
    else
      begin
        JSON.parse(body)
      rescue JSON::ParserError
        # TODO: Inform TDAmeritrade of invalid JSON in their response!
        JSON.parse(body[12..body.length])
      end
    end
  end
  def answers
    @answers ||= retrieve(URI.parse('https://covid-backend.deepset.ai/models/1/faq-qa'))['results'][0]['answers']
  end
end
