class Plyushkin::NilValue
  def method_missing(sym, *args)
    return nil
  end

  def valid?
    true
  end
end
