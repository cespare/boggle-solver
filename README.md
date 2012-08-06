A simple boggle solver written in Ruby for fun. It generates a random board and then prints out solutions.

## Usage

First you need to install the `fast_trie` gem:

    $ gem install fast_trie

Then run the solver:

    $ ruby solver.rb --random

This generates a random board and solves it. You can also input the board from stdin or a file:

    $ ruby solver.rb
    T  L  T  P
    N  E  N  G
    T  N  O  A
    B  I  S  A
    <C-d>

    $ ruby solver.rb your_board.txt
