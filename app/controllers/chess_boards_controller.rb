class ChessBoardsController < ApplicationController
  def create
    response = ChessBoard.new(params[:knight_position]).save

    render json: response
  rescue StandardError => e
    render json: { status: 'FAILED', message: e.message }
  end

  def get_shortest_path

  end
end
