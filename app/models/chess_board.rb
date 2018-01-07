class ChessBoard < ApplicationRecord
  include ApplicationHelper
  attr_reader :knight_position, :start_position, :end_position
  attr_accessor :visited_destinations

  POSSIBLE_MOVES = [[-2, 1], [-1, 2], [1, 2], [2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1]].freeze
  BOARD_SIZE = (1..8)

  def initialize(knight_position = nil, end_position = nil)
    @knight_position = knight_position
    @start_position = split_char(knight_position)
    @end_position = split_char(end_position)

    @visited_destinations = []
  end

  # Converts position to char
  # For Ex: (8,1) => H1
  def to_char(x, y)
    "#{char_mapping.key(x)}#{y}"
  end

  # Gets the shortest path from source to destination using BFS algorithm
  def shortest_path
    initial_position_obj = { position: start_position, source: {} }

    knights_path = [initial_position_obj]

    while knights_path.present?
      current_position = knights_path.shift

      position = current_position[:position]

      if position == end_position
        return path_to_destination(current_position, initial_position_obj)
      end

      add_possible_destination(position, current_position, knights_path)
    end
  end

  # Gets all next possible unvisited destinations
  def possible_destinations(position)
    possible_moves = possible_moves_in_board(position)

    possible_destinations = possible_moves.map do |move|
      [move[0] + position[0], move[1] + position[1]]
    end.uniq

    possible_destinations - visited_destinations
  end

  # Gets next possible moves constrained to board size
  def possible_moves_in_board(position)
    POSSIBLE_MOVES.select do |move|
      x = position[0] + move[0]
      y = position[1] + move[1]

      within_board?(x, y)
    end
  end

  # Returns the path taken to reach the destination
  def path_to_destination(knights_path, start_knight_movement)
    steps_taken = []
    loop do
      steps_taken << to_char(knights_path[:position][0], knights_path[:position][1])

      if knights_path == start_knight_movement
        return steps_taken.reverse.to_sentence
      end

      knights_path = knights_path[:source]
    end
  end

  # Saves the given knight's position and
  # returns the board id
  def save
    if valid_position?(knight_position)
      unique_board_id = board_id
      redis_conn.set(unique_board_id, knight_position)

      { status: :success, board_id: unique_board_id }
    else
      { status: :failed, message: "Invalid knight's position" }
    end
  end

  # Generates board id
  def board_id
    SecureRandom.hex
  end

  # Adds all possible destinations with respect to the knight's position
  def add_possible_destination(position, knights_action, knights_path)
    possible_destinations = possible_destinations(position)

    possible_destinations.each do |possible_destination|
      add_movement(possible_destination, knights_action, knights_path)
    end
  end

  # Add destination to visited destinations
  # Adds destination with respect to the action taken by knight and
  # adds the path taken to destination to src to track.
  def add_movement(destination, knights_action, knights_path)
    visited_destinations << destination
    knights_path << { position: destination, source: knights_action }
  end

  # Checks if the given position remains within the board
  def within_board?(x, y)
    BOARD_SIZE.include?(x) && BOARD_SIZE.include?(y)
  end

  # Checks if the position is valid
  def self.valid_position?(char)
    chess_board = ChessBoard.new
    position = chess_board.split_char(char)
    chess_board.within_board?(position[0], position[1])
  end

  # Maps the character to number
  def char_mapping
    @char_mapping ||= BOARD_SIZE.each_with_object({}) do |index, hash|
      hash[(96 + index).chr] = index
    end
  end

  # Gets the knight's position by providing baord id
  def self.find(board_id)
    redis_conn.get(board_id)
  end

  # Splits the chat to (x,y) position
  def split_char(char)
    return if char.nil?
    x, y = char.split('')
    [char_mapping[x.downcase], y.to_i]
  end
end
