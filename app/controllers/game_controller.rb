require 'open-uri'
require 'json'

class GameController < ApplicationController

  def run
    @grid = generate_grid(20)
    @start_time = Time.now
  end

  def score
    @shot = params[:shot]
    @grid = params[:grid].split(//)
    @start_time = Time.parse(params[:start])
    @end_time = Time.now
    @time = @end_time - @start_time
    @translation = get_translation(@shot)
    @score = score_and_message(@shot, @translation, @grid, @time)[0]
    @message = score_and_message(@shot, @translation, @grid, @time)[1]
    # @score = run_game(@shot, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    alphabet = [('A'..'Z')].map(&:to_a).flatten
    string = (0...(grid_size)).map { alphabet[rand(alphabet.length)] }.join
    grid = string.split(//)
    # TODO: generate random grid of letters
  end

  def fake_json
    {
        "outputs" => [
            {
                "output" => "pomme",
                "stats" => {
                    "elapsed_time" => 19,
                    "nb_characters" => 5,
                    "nb_tokens" => 1,
                    "nb_tus" => 1,
                    "nb_tus_failed" => 0
                }
            }
        ]
    }.to_json
  end

  def included?(guess, grid)
    guess.split(//).all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "b60296dd-a78a-4822-b41b-06b89f8d95b4"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end
end
