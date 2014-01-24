require 'net/http'

class Plyushkin::Service::Web
  attr_accessor :url

  def get(id)
    uri = URI("#{url}/#{id}")
    use_ssl = true if uri.scheme == "https"

    response = Net::HTTP.start(uri.host, uri.port, 
                               :use_ssl => use_ssl) do |http|
      request = Net::HTTP::Get.new(uri.to_s)
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def put(id, json)

  end

end
