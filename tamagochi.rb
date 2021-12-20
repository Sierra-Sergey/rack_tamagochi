require 'bundler/setup'
require 'create_html'
require_relative 'pet'

class Game
  def create_pet
    animals = %w[Cat Dog Lion Tiger Hamster]
    p 'Назовите Вашего питомца'
    name = gets.chomp
    if name.length < 3
      while name.length < 3
        p 'Имя должно состоять не менее чем из 3 симолов'
        name = gets.chomp
      end
    end
    @pet = Pet.new(animals.sample, name)
    puts "Появился #{@pet.animal} #{@pet.name}"
  end

  def html
    content = File.read("#{Dir.pwd}/template.html")

    content.gsub!('{{animal}}', @pet.animal.to_s)
    content.gsub!('{{name}}', @pet.name.to_s)
    content.gsub!('{{health}}', @pet.health.to_s)
    content.gsub!('{{bellyful}}', @pet.bellyful.to_s)
    content.gsub!('{{peppiness}}', @pet.peppiness.to_s)
    content.gsub!('{{mood}}', @pet.mood.to_s)
    content.gsub!('{{purity}}', @pet.purity.to_s)
    content.gsub!('{{toilet}}', @pet.toilet.to_s)
    content.gsub!('{{response}}', @pet.response.uniq.join('__').to_s)
    content.gsub!('__', '<br>')
    content.gsub!('{{emoji}}', "‍#{@pet.emoji}")

    create_html(content, true, 'pet.html')
  end

  def start
    create_pet
    html
    open('pet.html')
    @pet.help
    command = nil
    until command == 'exit'
      command = gets.chomp.strip
      case command
      when 'feed'   then @pet.feed
      when 'sleep'  then @pet.sleep
      when 'play'   then @pet.play_with_pet
      when 'toilet' then @pet.toil
      when 'bath'   then @pet.bath
      when 'toss'   then @pet.toss
      when 'heal'   then @pet.heal
      when 'sweets' then @pet.sweets
      when 'rock'   then @pet.rock
      when 'watch'  then @pet.watch
      when 'help'   then @pet.help
      when 'info'   then @pet.info
      else next
      end

      html
      exit if @pet.emoji == '&#127748;'
      @pet.response.clear

      next unless @pet.health <= 0

      @pet.health = 0
      @pet.emoji = '☠'
      @pet.response << (p 'Ваш питомец умер')
      html
      exit
    end
  end
end

Game.new.start
