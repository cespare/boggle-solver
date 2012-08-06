#!/usr/bin/env ruby

# To run:
# $ gem install fast_trie
# $ ruby solver.rb
# or
# $ ruby solver.rb --timing # print timing info


require "trie"
require "set"

global_start = Time.now
$timings = []
def time(description, start)
  elapsed = Time.now - start
  $timings << description.rjust(70) + ("  %0.5fs" % elapsed)
end

MINIMUM_WORD_LENGTH = 4
start = Time.now
WORD_LIST = File.read("./sowpods.txt").split("\n").map(&:strip).reject { |word| word.size < MINIMUM_WORD_LENGTH }
time "read word list from file:", start

DICE = [
  %w[T W O O T A],
  %w[H N E E W G],
  %w[S A F P K F],
  %w[E R L I D X],
  %w[Y E D L E V],
  %w[Y T D T I S],
  %w[V E H W T R],
  %w[M U O C T I],
  %w[U I E N S E],
  %w[N L N H Z R],
  %w[I S S O E T],
  %w[T R E T L R],
  %w[E A N A G E],
  %w[U N H I QU M],
  %w[O S C A H P],
  %w[O A B B J O],
]

class Board
  def initialize
    start = Time.now
    scrambled_dice = DICE.shuffle
    @tiles = Hash.new { |hash, key| hash[key] = {} }
    dice_index = 0
    4.times do |y|
      4.times do |x|
        @tiles[x][y] = scrambled_dice[dice_index].sample
        dice_index += 1
      end
    end
    time "generate a random board", start
  end

  # Get the value (e.g. "R", "QU") at a point (e.g. [1,2])
  def value_at(point) @tiles[point[0]][point[1]] end

  def to_s
    (0...4).reduce("") do |result, y|
      result << (0...4).reduce("") { |row, x| row << @tiles[x][y].ljust(3) } + "\n"
    end
  end

  def neighbors(point)
    x, y = point
    [-1, 0, 1].reduce([]) do |result, y_offset|
      result += [-1, 0, 1].reduce([]) do |result_row, x_offset|
        new_x = x + x_offset
        new_y = y + y_offset
        if (x_offset == 0 && y_offset == 0) || new_x < 0 || new_y < 0 || new_x > 3 || new_y > 3
          result_row
        else
          result_row << [new_x, new_y]
        end
      end
    end
  end

  def find_all_words
    start = Time.now
    word_trie = Trie.new
    WORD_LIST.each { |word| word_trie.add word }
    time "insert all the words into a new trie", start

    results = Set.new

    start = Time.now
    (0...4).each do |y|
      (0...4).each do |x|
        find_all_words_helper([x, y], word_trie.root, results)
      end
    end
    time "find all words once the trie has been created", start

    # Return the results with longest results first; sort alphabetically among those of the same size.
    results.to_a.sort do |first, second|
      comparison = second.size <=> first.size
      next comparison unless comparison == 0
      first <=> second
    end
  end

  # This helper will traverse recursively all possible points, walking the trie at the same time, until it
  # dead-ends (either the board or the trie). It will deposit its results into the result_set -- not very
  # functional, I suppose, but more efficient than constructing a bunch of intermediate `Set`s.
  def find_all_words_helper(current_point, trie_node, result_set, partial_word = "",
                            already_traversed_points = [])
    current_tile_value = value_at(current_point)
    current_partial_word = partial_word + current_tile_value
    current_trie_node = trie_node.walk(current_tile_value)

    # Bail if the trie has dead-ended
    return unless current_trie_node
    # Save the current word if it's in the dictionary
    result_set << current_partial_word if current_trie_node.terminal?
    # Bail if there are no children for this trie node (this is just an optimization)
    return if current_trie_node.leaf?

    possible_next_points = neighbors(current_point) - already_traversed_points
    possible_next_points.each do |next_point|
      find_all_words_helper(next_point, current_trie_node, result_set, current_partial_word,
                            already_traversed_points + [current_point])
    end
  end
end

board = Board.new
puts board
puts board.find_all_words

time "total", global_start
if ARGV.include? "--timing"
  puts <<-EOS

Timings
-------
EOS
  $timings.each { |timing| puts timing }
end
