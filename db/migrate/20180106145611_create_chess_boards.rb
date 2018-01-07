class CreateChessBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :chess_boards, &:timestamps
  end
end
