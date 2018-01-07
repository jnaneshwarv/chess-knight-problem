require 'rails_helper'

RSpec.describe ChessBoardsController, type: :controller do
  describe "Initialize the chess board with knight's position" do
    context 'If valid knight position is given' do
      it 'returns success with board id' do
        post :create, params: { knight_position: "H1" }
        expect(JSON.parse(response.body)['board_id']).to match(/^[a-zA-Z0-9]*$/)
      end
    end
    context 'If valid knight position is not given given' do
      it 'returns success with board id' do
        post :create, params: { knight_position: "I1" }
        expect(JSON.parse(response.body)['message']).to eq("Invalid knight's position")
      end
    end
  end

  describe 'Get the shortest path' do
    before(:all) do
      @board_id = ChessBoard.new('H1').save[:board_id]
    end

    context 'if valid board id is given' do
      it 'returns shortest path' do
        get :get_shortest_path, params: { board_id: @board_id, destination: 'G2'}
        expect(JSON.parse(response.body)['shortest_path']).to eq('H1, F2, D3, F4, and G2')
      end
    end

    context 'If invalid board id is given' do
      it 'returns invalid board ID' do
        get :get_shortest_path, params: { board_id: 'ceqweqw3', destination: 'G2'}
        expect(JSON.parse(response.body)['message']).to eq('Invalid board ID')
      end
    end

    context 'If invalid destination is given' do
      it 'returns invalid destination sent' do
        get :get_shortest_path, params: { board_id: @board_id, destination: 'I2'}
        expect(JSON.parse(response.body)['message']).to eq('Invalid destination sent')
      end
    end
  end

end
