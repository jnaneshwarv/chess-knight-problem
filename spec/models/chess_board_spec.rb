require 'rails_helper'

RSpec.describe ChessBoard, type: :model do
  before(:all) { @chess_board = ChessBoard.new('H1', 'G2') }
  context 'to_char' do
    it 'returns position of knight in char format' do
      expect(described_class.new.to_char(8, 1)).to eq 'H1'
    end
  end

  context 'shortest_path' do
    it 'returns shortest path taken by the knight' do
      expect(@chess_board.shortest_path).to eq 'H1, F2, D3, F4, and G2'
    end
  end

  context 'possible_destinations' do
    it 'returns next possible destination for a given position' do
      expect(described_class.new.possible_destinations([8, 1])).to eq([[6, 2], [7, 3]])
    end
  end

  context 'possible_moves_in_board' do
    it 'return all possible moves for a given position' do
      expect(described_class.new.possible_moves_in_board([8, 1])).to eq([[-2, 1], [-1, 2]])
    end
  end

  context 'path_to_destination' do
    it 'returns the path taken to reach destination' do
      inital_knight_position = { position: [8, 1], source: {} }
      knights_path = {
          position: [7, 2],
          source: {
              position: [6, 4],
              source: {
                  position: [4, 3],
                  source: {
                      position: [6, 2],
                      source: {
                          position: [8, 1],
                          source: {}
                      }
                  }
              }
          }
      }

      expect(described_class.new.path_to_destination(knights_path, inital_knight_position)).to eq('H1, F2, D3, F4, and G2')
    end
  end

  context 'save' do
    it "saves the board id into the redis if valid knight's position is given" do
      expect(described_class.new('H1').save[:board_id]).to match(/^[a-zA-Z0-9]*$/)
    end

    it "returns invalid knight's position if invalid knight's position is given" do
      expect(described_class.new('I1').save[:message]).to eq("Invalid knight's position")
    end
  end

  context 'board_id' do
    it 'returns board id' do
      expect(described_class.new.board_id).to match(/^[a-zA-Z0-9]*$/)
    end
  end

  context 'add_possible_destination' do
    it "returns all possible destinations with respect to the knight's position" do
      position = [6, 2]
      knights_action = {:position=>[6, 2], :source=>{:position=>[8, 1], :source=>{}}}
      knights_path = [{:position=>[7, 3], :source=>{:position=>[8, 1], :source=>{}}}]
      expected_result = [
          {
              :position=>[6, 2],
              :source=>{
                  :position=>[8, 1],
                  :source=>{}
              }
          }, {:position=>[7, 3], :source=>{:position=>[8, 1], :source=>{}}}
      ]
      result = described_class.new.add_possible_destination(position, knights_action, knights_path)
      expect(result).to eq([[4, 3], [5, 4], [7, 4], [8, 3], [4, 1], [8, 1]])
    end
  end

  context 'add_path' do
    it 'adds the path taken by the knight' do
      position = [7, 3]
      knights_action = {:position=>[8, 1], :source=>{}}
      knights_path = [{:position=>[6, 2], :source=>{:position=>[8, 1], :source=>{}}}]
      expected_result = [
          {
              :position=>[6, 2],
              :source=>{
                  :position=>[8, 1],
                  :source=>{}
              }
          }, {:position=>[7, 3], :source=>{:position=>[8, 1], :source=>{}}}
      ]
      result = described_class.new.add_path(position, knights_action, knights_path)
      expect(result).to eq(expected_result)
    end
  end

  context 'within_board?' do
    it 'returns true if valid knight position is given' do
      expect(described_class.new.within_board?(8, 1)).to eq(true)
    end

    it 'returns false if invalid knight position is given' do
      expect(described_class.new.within_board?(11, 1)).to eq(false)
    end
  end

  context 'valid_position?' do
    it 'returns true if valid knight position is given' do
      expect(described_class.valid_position?('H1')).to eq(true)
    end

    it 'returns false if invalid knight position is given' do
      expect(described_class.valid_position?('I1')).to eq(false)
    end
  end

  context 'char_mapping' do
    it 'returns char mapping to numbers object' do
      expect(described_class.new.char_mapping).to eq({"a"=>1, "b"=>2, "c"=>3, "d"=>4, "e"=>5, "f"=>6, "g"=>7, "h"=>8})
    end
  end

  context 'split_char' do
    it 'returns position of knight from char' do
      expect(described_class.new.split_char('H1')).to eq([8, 1])
    end
  end
end
