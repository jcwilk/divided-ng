class CollisionSimulator
  VERTICAL = :vertical #slope going straight up and down
  RESOLUTION = 10 #how many time slices to check for collisions

  def initialize
    @participants = []
  end

  def add_participant(initial:,final:,id:)
    if initial[0] == final[0]
      slope = VERTICAL
      slice_size = (final[1] - initial[1]).to_f/RESOLUTION
    else
      slope = (final[1] - initial[1]).to_f/(final[0] - initial[0])
      slice_size = (final[0] - initial[0]).to_f/RESOLUTION
    end
    @participants << {initial: initial, slope: slope, slice_size: slice_size, id: id}
  end

  def collisions
    found = []
    moving = @participants.select {|p| p[:slice_size] != 0 }
    current = {}
    @participants.each do |p|
      current[p[:id]] = p[:initial]
    end

    (0..RESOLUTION).each do |slice|
      moving.each do |m|
        if m[:slope] == VERTICAL
          x = m[:initial][0]
          y = m[:initial][1]+m[:slice_size]*slice
        else
          x = m[:initial][0]+m[:slice_size]*slice
          y = m[:initial][1]+m[:slope]*m[:slice_size]*slice
        end

        new_pos = [x.round,y.round]
        others = current.select {|k,v| k != m[:id] }

        if others.any? {|id,pos| pos == new_pos }
          found << {id: m[:id], final: current[m[:id]]}
          moving.delete(m)
        else
          current[m[:id]] = new_pos
        end
      end
    end

    found
  end
end
