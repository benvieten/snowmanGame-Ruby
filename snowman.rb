require 'ruby2d'

# Returns a display string for the word, showing underscores for unguessed letters.
def update_word_display(chosen_word, guessed_letters)
  chosen_word.chars.map do |char|
    if char.match?(/[A-Za-z']/) #I dont actually know if this works for apostrophes, haven't gotten a word with one
      guessed_letters.include?(char.downcase) ? char : "_"
    else
      char
    end
  end.join(" ")
end

def prompt_new_game(event)
  if event.key == 'return'
    clear
    Text.remove
    return false
  end
  
  true
end

# Draw the snowman parts based on the number of incorrect guesses.
# 1. Base circle
def draw_snowman(incorrect_guesses)
  parts = []
  center_x = 600  # Adjust x position as desired
  base_y = 400    # y position for the bottom of the snowman
  
  if incorrect_guesses >= 1
    parts << Circle.new(
      x: center_x, y: base_y,
      radius: 50, sectors: 32,
      color: 'white', z: 10
    )
  end
  # 2. Middle circle
  if incorrect_guesses >= 2
    parts << Circle.new(
      x: center_x, y: base_y - 70,
      radius: 35, sectors: 32,
      color: 'white', z: 10
    )
  end
  # 3. Head circle
  if incorrect_guesses >= 3
    parts << Circle.new(
      x: center_x, y: base_y - 70 - 50,
      radius: 25, sectors: 32,
      color: 'white', z: 10
    )
  end
  # 4. Hat
  if incorrect_guesses >= 4
    parts << Square.new(
      x: center_x - 15, y: base_y - 70 - 50 - 25 - 5 - 30,
      size: 30, color: 'white',
      z: 30
    )
    parts << Rectangle.new(
      x: center_x - 25, y: base_y - 70 - 50 - 25 - 5,
      width: 50, height: 10,
      color: 'white',
      z: 20
    )
  end
  # 5. Left Arm
  if incorrect_guesses >= 5
    parts << Line.new(
      x1: center_x - 30, y1: base_y - 70,
      x2: center_x - 75, y2: base_y - 70 - 35,
      width: 5, color: 'white', z: 20
    )
  end
  # 6. Right Arm
  if incorrect_guesses >= 6
    parts << Line.new(
      x1: center_x + 30, y1: base_y - 70,
      x2: center_x + 75, y2: base_y - 70 - 35,
      width: 5, color: 'white', z: 20
    )
  end
  
  parts
end

# Remove previously drawn snowman parts.
def clear_snowman(parts)
  parts.each(&:remove)
  parts.clear
end

def start_new_game()
  clear
  # Load dictionary file and select a random word.
  $words = File.readlines("dictionary.txt").map(&:chomp).reject(&:empty?)
  $chosen_word = $words.sample
  $word_lower = $chosen_word.downcase

  # Game state variables.
  $guessed_letters = []
  $incorrect_guesses = 0
  $max_incorrect = 6
  $game_over = false
  $guess_buffer = ""
  $snowman_parts = []

  # UI elements for displaying game information.
  $word_text = Text.new(update_word_display($chosen_word, $guessed_letters), x: 20, y: 20, size: 30)
  $guess_text = Text.new("Your guess: ", x: 20, y: 70, size: 20)
  $guessed_letters_text = Text.new("Guessed letters: ", x: 20, y: 100, size: 20)
  $message_text = Text.new("", x: 20, y: 130, size: 20)
  $game_over_text = Text.new("", x: 75, y: 275, size: 40)
end

# Load dictionary file and select a random word.
$words = File.readlines("dictionary.txt").map(&:chomp).reject(&:empty?)
$chosen_word = $words.sample
$word_lower = $chosen_word.downcase

# Game state variables.
$guessed_letters = []
$incorrect_guesses = 0
$max_incorrect = 6
$game_over = false
$guess_buffer = ""
$snowman_parts = []

# UI elements for displaying game information.
$word_text = Text.new(update_word_display($chosen_word, $guessed_letters), x: 20, y: 20, size: 30)
$guess_text = Text.new("Your guess: ", x: 20, y: 70, size: 20)
$guessed_letters_text = Text.new("Guessed letters: ", x: 20, y: 100, size: 20)
$message_text = Text.new("", x: 20, y: 130, size: 20)
$game_over_text = Text.new("", x: 75, y: 275, size: 40)

on :key_down do |event|
  # If the game is over, only allow restarting by pressing return.
  if $game_over
    if event.key == 'return'
      start_new_game()
      $game_over = false
    end
    next
  end

  if event.key == 'return'
    unless $guess_buffer.empty?
      guess = $guess_buffer.downcase
      $guess_buffer = ""
      if guess.length > 1
        $message_text.text = "Please enter a single letter."
      elsif $guessed_letters.include?(guess)
        $message_text.text = "Already guessed '#{guess}'."
      else
        $guessed_letters << guess
        if $word_lower.include?(guess)
          $message_text.text = "Good guess!"
        else
          $message_text.text = "Incorrect guess."
          $incorrect_guesses += 1
        end
      end

      # Update displays.
      $word_text.text = update_word_display($chosen_word, $guessed_letters)
      $guessed_letters_text.text = "Guessed letters: #{$guessed_letters.join(', ')}"
      $guess_text.text = "Your guess: "

      # Redraw the snowman.
      clear_snowman($snowman_parts)
      $snowman_parts = draw_snowman($incorrect_guesses)

      # Check win condition.
      if update_word_display($chosen_word, $guessed_letters).gsub(" ", "").downcase == $word_lower
        $message_text.text = "The word was: #{$chosen_word}"
        $game_over_text.text = "You Win!"
        Text.new("Press [Enter] to Play Again!", x: 75, y: 325, size: 25)
        $game_over = true
      elsif $incorrect_guesses >= $max_incorrect
        $message_text.text = "The word was: #{$chosen_word}"
        $game_over_text.text = "Game Over!"
        Text.new("Press [Enter] to Play Again!", x: 75, y: 325, size: 25)
        $game_over = true
      end
    end
  elsif event.key == 'backspace'
    $guess_buffer.chop!
    $guess_text.text = "Your guess: " + $guess_buffer
  else
    # Append single character keys to the guess buffer.
    if event.key.length == 1
      $guess_buffer << event.key
      $guess_text.text = "Your guess: " + $guess_buffer
    end
  end
end

set title: "Snowman Word Game", width: 800, height: 600
show
