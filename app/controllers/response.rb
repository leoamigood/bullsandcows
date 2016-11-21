class Response

  def to_json(options = {})
    self.to_hash.to_json
  end

  def to_hash
    Hash[self.instance_variables.map{|attribute| [attribute.to_s.sub("@",""), self.instance_eval(attribute.to_s)] }]
  end

end
