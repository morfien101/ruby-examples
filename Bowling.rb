# Bowling.rb
# Bowling Scores
# The goal of this program is to model a game of bowling. Given a series of
# input the program should output the players final score.
#
# Specification/Rules of Bowling
# Each game, or line of bowling, includes ten turns, or frames for the bowler.
# In each frame, the bowler gets up to two tries to knock down all the pins.
# If in two tries, he fails to knock them all down, his score for that frame is
# the total number of pins knocked down in his two tries.
# If in two tries he knocks them all down, this is called a spare and his score
# for the frame is ten plus the number of pins knocked down on his next
# throw (in his next turn).
# If on his first try in the frame he knocks down all the pins, this is
# called a strike. 
# His turn is over, and his score for the frame is ten plus the simple
# total of the pins knocked down in his next two rolls.
# If he gets a spare or strike in the last (tenth) frame, the bowler gets to
# throw one or two more bonus balls, respectively. These bonus throws are
# taken as part of the same turn.
# If the bonus throws knock down all the pins, the process does not repeat:
# the bonus throws are only used to calculate the score of the final frame.
# The game score is the total of all frame scores.
#
# We will not check
# Valid rolls
# Correct number of rolls and frames.
# We will not provide scores for intermediate frames.
#
# Example input and output
# Example 1: Gutter balls (all zero)
# [0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]
# -> 0
# Example 2: All Threes
# [3,3],[3,3],[3,3],[3,3],[3,3],[3,3],[3,3],[3,3],[3,3],[3,3]
# -> 60
# Example 3: All Spares with first ball a 4
# [4,6],[4,6],[4,6],[4,6],[4,6],[4,6],[4,6],[4,6],[4,6],[4,6,4]
# -> 140
# Example 4: Nine Strikes followed by a gutter ball
# [10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[0,0]
# -> 240
# Example 5: Perfect Game
# [10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,0],[10,10,10]
# -> 300

# This class will hold the players scoring data.
class Player
  def initialize
    # Players get 10 turns plus a bonus roll should they get a strike or spare
    # on the last turn.
    @turns = [[0, 0]] * 9 + [[0, 0, 0]]
  end

  def add_score(turn,t1=0,t2=0,t3=nil)
    # each turn we get the vaules of the pins knoxkd down. 
    @turns[turn] = [t1, t2]
    @turns[turn][2] = t3 unless t3.nil?
  end

  def total_score
    score = 0
    @turns.each_index do |turni|
      # We need to work out the score and apply the game scoring rules here.
      if turni == 9
        if @turns[turni][0] == 10 || @turns[turni][0] + @turns[turni][1] == 10
          # Strike. If the player gets a strike the sum of the next
          # turn is added up.
          score += @turns[turni][0] + @turns[turni][1] + @turns[turni][2]
        else
          score += @turns[turni][0] + @turns[turni][1]
        end
      else
        if @turns[turni][0] == 10
          # Strike. If the player gets a strike the sum of the next
          # turn is added up.
          # we also need to check if the player scores a strike on the next turn
          # as we need to add the next 2 ROLLS. A player ends thier turn on a
          # strike.
          if turni == 8
            score += @turns[turni + 1][0] + @turns[turni + 1][1]
          else
            if @turns[turni+1][0] == 10
              score += @turns[turni + 1][0] + @turns[turni + 2][0]
            end
          end
        elsif @turns[turni][0] + @turns[turni][1] == 10
          # Spare. If the player knocks all the pins down in 2 throws then the
          # next turn they get what ever they know down on throw 1 added
          # to this score.
          score += @turns[turni + 1][0]
        end
        score += @turns[turni][0] + @turns[turni][1]
      end
    end
    return score
  end
end

randy = Player.new
games = [
  [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]],
  [[3, 3], [3, 3], [3, 3], [3, 3], [3, 3], [3, 3], [3, 3], [3, 3], [3, 3], [3, 3]],
  [[4, 6], [4, 6], [4, 6], [4, 6], [4, 6], [4, 6], [4, 6], [4, 6], [4, 6], [4, 6, 4]],
  [[10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [0, 0]],
  [[10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 10, 10]]
]

games.each do |play|
  play.each_index do |turn|
    if turn == 9
      if play[turn][0] == 10 || play[turn][0] + play[turn][1] == 10
        randy.add_score(turn, play[turn][0], play[turn][1], play[turn][2])
      else
        randy.add_score(turn, play[turn][0], play[turn][1], 0)
      end
    else
      randy.add_score(turn, play[turn][0], play[turn][1])
    end
  end
  puts randy.total_score
end
