class Plyushkin::Service::Stub

  def initialize
    @store = {}
  end

  def get(id)
    JSON.parse(@store[id] || "{}")
  end

  def put(id, json)
    @store[id] = json
  end

end
