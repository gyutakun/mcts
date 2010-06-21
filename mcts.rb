class Tree
	attr_accessor :root_node #game starting state
	attr_accessor :current_node #current state of play
	attr_accessor :game, :node_count

	UCT_C = 1.0 	# constant in UCT score formula
	RANDOM_MOVES_PER_NODE = 30

	def initialize(game)
		@game = game		
		@node_count = 0
		@root_node = Node.new(self, game, false, false)
		@current_node = @root_node
	end

	def pick_move		#should probably add state as parameter; then search tree for that state and set as current_node
		#TO DO: check to see if game is over in current_node		

		select(current_node)

	end

	def select(node)
		if node.result
      backpropagate(node, node.result)
		elsif play_random_move?(node)			
			playout(node)
		else
			select(select_by_strategy(node)) # pick top child node and recurse to select
		end
	end

	def play_random_move?(node)
		node.visits <= RANDOM_MOVES_PER_NODE
	end

	def select_by_strategy(node)
		# have all children been visited?
		# has the number of visits been 
		node.children.sort {|a, b| a.uct_score <=> b.uct_score}.reverse[0] #returns top-scoring child node
	end

	def backpropagate(node, winner)
		node.record_visit(winner)
		backpropagate(node.parent, winner) if node.parent #recursively record visits up tree
	end

	def playout(starting_node)
		#create new game object based on starting node state		
		new_game = @game.class.new_from_state(starting_node.state)

		#do one random move in new game object
		move = new_game.do_random_move

		#create/retrieve child node based on that random move
		new_node = starting_node.has_child(move)
		unless new_node
			new_node = Node.new(self, new_game, starting_node, move)
			starting_node.children << new_node
		end
		
		#new game randomly self plays till game end
		result = new_game.playout
		
		#backpropagate result
		backpropagate(new_node, result)
	end
end

class Node

	attr_accessor :tree, :state, :parent, :prior_move, :children, :result, :visits, :cum_score
	
	def initialize(tree, game, parent, prior_move)		
		@tree = tree
		@tree.node_count += 1
		@state = game.class.cloned_state(game.state)
		@parent = parent
		@prior_move = prior_move
		@children = []
		@result = game.result
		@visits = 0
		@cum_score = 0
	end

	def has_no_children?
		@children.size == 0
	end
	
	def has_child(move)
		@children.each do |child|
			return child if child.prior_move == move		#requires comparison operator to work on moves
		end
		return nil
	end
		
	def uct_score
		value + Tree::UCT_C * Math.sqrt(Math.log(@parent.visits) / @visits)
	end

	def value
		@cum_score.to_f / @visits
	end

	def record_visit(winner)
		@visits += 1
		if winner == @state[:whose_turn]
			@cum_score += 1
		elsif winner != :tie
			@cum_score += -1
		end
	end

	def to_s
		@tree.game.class.new_from_state(@state).to_s
	end

end
