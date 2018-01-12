## Chess knight problem
This project intends to find the shortest path taken by a knight from source to destination in a chess board.

## Setup
* Run `bundle install` to install all gems
* Run `rails s` to start the server.

## Actions
There are two end points for this problem. 
* First end pint takes the inital position of the knight
End-point: http://localhost:3000/chess_boards
Method: POST
Params: {
	"knight_position": "H1"
}
Response: You will get success status along with unique id called board_id


* The other end point takes the board_id that was taken from previous end point's response.
End-point: http://localhost:3000/chess_boards/get_shortest_path
Method: GET
Params: {
	board_id: <string>,
  destination: G2
}
Response: You will get the shortest path taken by knight as response(H1, G3, H5, F4, and G2).
