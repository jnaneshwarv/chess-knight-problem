class ChessBoardsController < ApplicationController
  include ApplicationHelper

  def create
    response = ChessBoard.new(params[:knight_position]).save

    render json: response
  rescue StandardError => e
    render json: { status: :failed, message: e.message }
  end

  def get_shortest_path
    knight_position = redis_conn.get(params[:board_id])
    if knight_position.blank?
      render(json: { status: :failed, message: 'Invalid board ID' }) && return
    end
    end_position = params[:destination]
    unless ChessBoard.valid_position?(end_position)
      render(json: { status: :failed, message: 'Invalid destination sent' }) && return
    end

    render json: {
      status: :success,
      shortest_path: ChessBoard.new(knight_position, end_position).shortest_path
    }
  end
end
