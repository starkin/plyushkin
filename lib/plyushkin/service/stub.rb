class Plyushkin::Service::Stub

  def initialize
    @store = {}
  end

  def get(id)
    JSON.parse(@store[id] || "{}")
  end

  def put(id, payload)
    @store[id] = payload.to_json
  end

end
