require 'set'
require 'securerandom'
require 'graphviz'

PushdownAutomaton = Struct.new(
  :input_alphabet,
  :stack_alphabet,
  :states,
  :initial_state,
  :final_states,
  :initial_stack_item,
  :transition_function
) do
  def all_nop_transition_keys
    input_alphabet.flat_map do |input|
      stack_alphabet.map do |stack|
        [input, stack]
      end
    end
  end 

  def construct_from_pieces(pieces)
    raise 'no pieces' if pieces.empty?

    self.initial_state = pieces.first.entry_state
    self.final_states = pieces.flat_map(&:final_states).to_set
    self.states = pieces.flat_map { |x| x.states.to_a }.to_set

    self.transition_function = {}
    pieces.each_cons(2) do |this_piece, next_piece|
      transition_function.merge!(this_piece.transition_function)

      transition_function.merge!(this_piece.transitions_out
        .map { |k, v| [k, [v, next_piece.entry_state ]] }.to_h)
    end
  end

  def to_graphviz
    graph = Graphviz::Graph.new("Pushover Compilation")

    state_nodes = {}
    states.each do |state|
      state_nodes[state] = graph.add_node(state.to_s[0..6] + "...")
    end
    p state_nodes.keys

    transition_function.each do |k, v|
      input, stack_pop, from = k
      stack_push, to = v

      state_nodes[from].connect(state_nodes[to],
        { label: "#{input}, #{stack_pop} / #{stack_push.map(&:to_s).join(", ")}" })
    end

    graph
  end
end

PushdownAutomatonPiece = Struct.new(
  :automaton,
  :states,
  :entry_state,
  :final_states,
  :transition_function,
  :transitions_out
)

def create_accept_piece(automaton)
  s0 = SecureRandom.uuid.to_sym

  PushdownAutomatonPiece.new(
    automaton,
    Set[s0],
    s0,
    Set[s0],
    {},
    automaton.all_nop_transition_keys.map { |k| [k + [s0], [k[1]]] }.to_h
  )
end

def create_reject_piece(automaton)
  s0 = SecureRandom.uuid.to_sym

  PushdownAutomatonPiece.new(
    automaton,
    Set[s0],
    s0,
    Set[s0],
    automaton.all_nop_transition_keys.map { |k| [k + [s0], [[k[1]], s0]] }.to_h,
    {}
  )
end

pda = PushdownAutomaton.new(
  Set[:a, :b, :c],
  Set[:"0", :"1"],
  Set[],
  nil,
  Set[],
  :Z,
  {}
)

pda.construct_from_pieces([create_accept_piece(pda), create_accept_piece(pda)])
p pda

puts pda.to_graphviz.to_dot