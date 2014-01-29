class Plyushkin::Service::Stub

  def initialize
    @models = {}
  end

  def get(model, id)
    JSON.parse(get_store(model)[id] || "{}")
  end

  def put(model, id, payload)
    get_store(model)[id] = payload.to_json
  end

  private
  def get_store(model)
    if @models[model]
      store = @models[model]
    else
      store = @models[model] = {}
    end
  end

end
