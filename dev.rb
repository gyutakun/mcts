load "game.rb"
load "mcts.rb"

class Ttt

	attr_accessor :g, :t

	def initialize(trials)
		
		@g = TicTacToe.new
		@t = Tree.new(@g)
		trials.times {@t.select(@t.root_node)}
		
	end
	
end
		
