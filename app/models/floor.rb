class Floor
  def open?(coord)
    coord.x >= 0 && coord.x <= 9 && coord.y >= 0 && coord.y <= 9
  end
end
