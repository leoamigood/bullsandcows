class User

  rattr_initialize :id, :name

  def ==(other)
    @id == other.id
  end

end
