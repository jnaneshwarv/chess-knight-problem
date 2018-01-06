class CreateChessBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :chess_boards do |t|

      t.timestamps
    end
  end
end
