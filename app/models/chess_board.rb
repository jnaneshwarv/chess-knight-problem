class ChessBoard < ApplicationRecord
  include ApplicationHelper

  attr_reader :knight_position
  BOARD_SIZE = (1..8)

  def initialize(knight_position)
    @knight_position = knight_position
  end

  def save
    if ChessBoard.is_valid_position(knight_position)
      unique_board_id = board_id
      redis_conn.set(unique_board_id, knight_position)

      { status: 'OK', board_id: unique_board_id, po:  redis_conn.get(unique_board_id)}
    else
      { status: 'FAILED', message: 'Invalid Knight Position' }
    end
  end

  def move_within_board(x, y)
    BOARD_SIZE.include?(x) && BOARD_SIZE.include?(y)
  end

  def self.is_valid_position(char)
    chess_board = ChessBoard.new(char)
    position = chess_board.split_char_to_position(char)
    chess_board.move_within_board(*position)
  end

  def char_index_mapping
    @char_index_mapping ||= BOARD_SIZE.each_with_object({}) do |index, hash|
      hash[(96+index).chr] = index
    end
  end

  def self.find(board_id)
    redis_conn.get(board_id)
  end

  def split_char_to_position(char)
    x, y = char.split('')
    [char_index_mapping[x.downcase], y.to_i]
  end

  private

  def board_id
    SecureRandom.hex
  end

end
