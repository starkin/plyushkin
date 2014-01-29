require 'net/http'

class Plyushkin::Service::Web
  attr_accessor :url

  def initialize(opts={})
    @url = opts.delete(:url)
  end

  def get(model, id)
    uri = URI("#{url}/#{model}/#{id}")
    use_ssl = true if uri.scheme == "https"

    response = Net::HTTP.start(uri.host, uri.port, 
                               :use_ssl => use_ssl) do |http|
      request = Net::HTTP::Get.new(uri.to_s)
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def put(model, id, payload)
    uri = URI("#{url}/#{model}/#{id}")
    use_ssl = true if uri.scheme == "https"

    response = Net::HTTP.start(uri.host, uri.port, 
                               :use_ssl => use_ssl) do |http|
      request = Net::HTTP::Put.new(uri.to_s)
      request.body = payload.to_json
      http.request(request)
    end
  end

end
