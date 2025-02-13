


def select_word
  filename = "dictionary.txt"
  lexicon = File.open(filename)
  words = lexicon.readlines
  lexicon.close
  game_word = words.sample.chomp
  game_word
end

def init
  @guess_limit = 6
  @game_word = select_word
  @guessed_letters = []
end

def game_over?
  if @guess_limit.zero?
    puts "You lose!"
    puts "The word was: #{@game_word}"
    true
  elsif @game_word.chars.all? { |char| @guessed_letters.include?(char) || char == " " }
    puts "You win!"
    true
  else
    false
  end
end

def display_word
  @game_word.each_char do |char|
    if @guessed_letters.include?(char) || char == " "
      print char
    else
      print "_"
    end
  end
  puts
end

def play_game
  init
  puts "Welcome to Snowman! You have #{@guess_limit} guesses to guess the word."
  puts "Here is your word: "
  display_word

  until game_over?
    puts "Please guess a letter or punctuation: "
    guess = gets.chomp.downcase

    if @guessed_letters.include?(guess)
      puts "You already guessed that letter!"
      next
    end

    @guessed_letters.push(guess)

    if @game_word.include?(guess)
      puts "Correct!"
    else
      puts "Incorrect!"
      @guess_limit -= 1
      puts "You have #{@guess_limit} guesses left."
    end

    display_word
  end
end

play_game