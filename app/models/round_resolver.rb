class RoundResolver
  class Movement
    attr_reader :room_participant, :coord

    delegate :uuid, :action, to: :selected_move
    delegate :x, :y, to: :coord

    def initialize(start_coord:, selected_move:, room_participant:)
      self.start_coord = start_coord
      self.selected_move = selected_move
      self.room_participant_uuid = room_participant.uuid
      self.coord = selected_move.coord

      generate_path
    end

    def backup
      if coord.x < start_coord.x
        self.coord = Coord.new(coord.x+1,coord.y)
      elsif coord.x > start_coord.x
        self.coord = Coord.new(coord.x-1,coord.y)
      end

      if coord.y < start_coord.y
        self.coord = Coord.new(coord.x,coord.y+1)
      elsif coord.y > start_coord.y
        self.coord = Coord.new(coord.x,coord.y-1)
      end
    end

    def move_uuid
      selected_move.uuid
    end

    def room_participant
      RoomParticipant.by_uuid(room_participant_uuid)
    end

    private

    attr_writer :coord
    attr_accessor :selected_move, :path, :room_participant_uuid, :start_coord

    def generate_path
      self.path = [coord]
    end
  end

  include Callable

  def initialize(room_participants:, move_selections: [], round:)
    self.room_participants = room_participants
    self.move_selections = move_selections
    self.round = round

    store_join_coords
  end

  def call
    participants = generate_participants

    Round.new.tap do |next_round|
      participants.each do |participant|
        participant.round_uuid = next_round.uuid
      end

      next_round.participants = participants
    end
  end

  private

  attr_accessor :room_participants, :move_selections, :round, :join_coords

  delegate :participant_by_user_uuid, :participating_user_uuid?, to: :round, private: true

  def store_join_coords
    all_coords = ((0..9).to_a.product (0..9).to_a).map { |x, y| Coord.new(x, y) }
    self.join_coords = all_coords - round.participants.map(&:coord)
  end

  def next_join_coord
    join_coords.shift
  end

  def generate_participants
    movements = continuing_participants + joining_participants

    resolve_conflicts(movements)

    next_participants = movements.map do |movement|
      RoundParticipant.new(
        movement.room_participant,
        move: movement
      )
    end

    next_participants.each do |participant|
      participant.moves = MovesGenerator.call(
        participant,
        participants: next_participants
      )
    end
  end

  def continuing_participants
    room_participants.select { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      move_selection = move_selections.find { |ms| ms.user_uuid == room_participant.user_uuid }
      old_round_participant = round.participant_by_user_uuid(room_participant.user_uuid)

      selected_move = if move_selection
          old_round_participant.move_by_uuid(move_selection.move_uuid)
        else
          old_round_participant.move_by_action(Move::IDLE_ACTION)
        end

      Movement.new(
        start_coord: old_round_participant.coord,
        selected_move: selected_move,
        room_participant: room_participant
      )
    end
  end

  def joining_participants
    room_participants.reject { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      join = MoveGenerator::Join.call(next_join_coord)
      Movement.new(
        start_coord: join.coord,
        selected_move: join,
        room_participant: room_participant
      )
    end
  end

  def resolve_conflicts(movements)
    remaining_loops = 100
    loop do
      remaining_loops -= 1
      if remaining_loops <= 0
        raise "too many loops!"
      end


      conflicting = movements.select { |m1| movements.any? { |m2| m1.coord == m2.coord && m1.move_uuid != m2.move_uuid } }

      break if conflicting.empty?

      conflicting.each(&:backup)
    end
  end
end
