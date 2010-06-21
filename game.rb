class Game

	attr_accessor :state

	def self.cloned_state(state_to_clone)
		Marshal.load(Marshal.dump(state_to_clone))
	end

	def self.new_from_state(state)
		new_game = self.new
		new_game.state = self.cloned_state(state)
		return new_game
	end

	def do_random_move
		move = pick_random_move
		do_move(move)
		return move
	end

	def playout
		unless result
			do_random_move
		else
			return result
		end 
	end

	def pick_random_move			# can be overridden with better game-specific pseudo-random logic
		legal_moves[rand(legal_moves.size)]
	end

end

class TicTacToe < Game

	WINNING_LINES = [
										[ [0,0], [0,1], [0, 2] ],
										[ [1,0], [1,1], [1, 2] ],
										[ [2,0], [2,1], [2, 2] ],
										[ [0,0], [1,0], [2, 0] ],
										[ [0,1], [1,1], [2, 1] ],
										[ [0,2], [1,2], [2, 2] ],
										[ [0,0], [1,1], [2, 2] ],
										[ [2,0], [1,1], [0, 2] ]
									]

	def initialize
		@state = {:board =>
						[	[' ', ' ', ' '], 
							[' ', ' ', ' '],
							[' ', ' ', ' '] ],
							:whose_turn => 0
							}
	end

	def legal_moves
		#need to check for game ending?
		result = []		
		@state[:board].each_with_index do |row, y|
			row.each_with_index do |mark, x|
				result << [x, y] if mark == ' '
			end		
		end
	return result
	end

	def to_s
		result = ""		
		@state[:board].each_with_index do |row, y|
			row.each_with_index do |mark, x|
				result << mark
			end
			result << "\n"
		end
		return result
	end

	def current_mark
		if @state[:whose_turn] == 0
			return 'X'
		else
			return 'O'
		end
	end

	def change_turn
		if @state[:whose_turn] == 0
			@state[:whose_turn] = 1
		else
			@state[:whose_turn] = 0
		end
	end		

	def do_move(move)		
		@state[:board][move[1]][move[0]] = current_mark
		change_turn
	end

	def result
		WINNING_LINES.each do |line|
			if same_mark?(line[0], line[1], line[2])
				if mark_at_position(line[0]) == 'X'
					return 0 #first player won
				else
					return 1	#second player won
				end
			end
		end
		blanks = 0
		@state[:board].each_with_index do |row, y|
			row.each_with_index do |mark, x|
				blanks += 1 if mark == ' '
			end
		end
		return :tie if blanks == 0 # game ended in tie
		return false	 # game not over
	end

	def same_mark?(a, b, c)
		return false if mark_at_position(a) == ' '
		mark_at_position(a) == mark_at_position(b) and mark_at_position(b) == mark_at_position(c)
	end

	def mark_at_position(a)
		@state[:board][a[1]][a[0]]
	end		
end

