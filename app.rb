require 'erb'

class Pet
  def self.call(env)
    new(env).response.finish
  end

  def render(file_name)
    path = File.expand_path("./views/#{file_name}")
    ERB.new(File.read(path)).result(binding)
  end

  def response
    case @req.path
    when '/'
      Rack::Response.new(render('enter_name.html.erb'))

    when '/initialize'
      @name = @req.params['pet_name'] unless @req.params['pet_name'].empty?
      Rack::Response.new do |response|
        response.set_cookie('name', @name)
        response.set_cookie('health', @health)
        response.set_cookie('bellyful', @bellyful)
        response.set_cookie('peppiness', @peppiness)
        response.set_cookie('mood', @mood)
        response.set_cookie('purity', @purity)
        response.set_cookie('toilet', @toilet)
        response.set_cookie('emoji', @emoji)
        response.set_cookie('phrases', @phrases)
        response.redirect('/game')
      end

    when '/game'
      if @req.cookies['health'].to_i <= 0 || @req.cookies['phrases'].include?('навсегда')
        Rack::Response.new do |response|
          response.redirect('/over')
        end
      else
        Rack::Response.new(render('game.html.erb'))
      end

    when '/change'
      @health = @req.cookies['health'].to_i
      @bellyful = @req.cookies['bellyful'].to_i
      @peppiness = @req.cookies['peppiness'].to_i
      @mood = @req.cookies['mood'].to_i
      @purity = @req.cookies['purity'].to_i
      @toilet = @req.cookies['toilet'].to_i

      case @req.params['action']
      when 'feed'   then feed
      when 'sleep'  then sleep
      when 'play'   then play_with_pet
      when 'toilet' then toil
      when 'bath'   then bath
      when 'toss'   then toss
      when 'heal'   then heal
      when 'sweets' then sweets
      when 'rock'   then rock
      when 'watch'  then watch
      end

      Rack::Response.new do |response|
        response.set_cookie('health', @health)
        response.set_cookie('bellyful', @bellyful)
        response.set_cookie('peppiness', @peppiness)
        response.set_cookie('mood', @mood)
        response.set_cookie('purity', @purity)
        response.set_cookie('toilet', @toilet)
        response.set_cookie('emoji', @emoji)
        response.set_cookie('phrases', @phrases.uniq.join('<br>'))
        response.redirect('/game')
      end

    when '/reset'
      Rack::Response.new do |response|
        response.redirect('/')
      end

    when '/over'
      Rack::Response.new(render('over.html.erb'))

    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def initialize(env)
    @req       = Rack::Request.new(env)
    @name      = 'Pet'
    @health    = 100
    @bellyful  = 100
    @peppiness = 100
    @mood      = 100
    @purity    = 100
    @toilet    = 100
    @asleep    = false
    @emoji     = '&#128515;'
    @stats     = [@health, @bellyful, @peppiness, @mood, @purity, @toilet]
    @phrases   = []
    # puts "У Вас появился #{@animal} #{@name}"
  end

  def feed
    @eating = true
    @bellyful = 100
    @phrases << (p 'Вы покормили питомца')
    pass_of_time
    @eating = false
  end

  def sleep
    if @peppiness > 75
      @phrases << (p 'Питомец не хочет спать')
      return
    end

    @asleep = true
    @phrases << (p 'Вы уложили питомца спать')
    3.times { pass_of_time if @asleep }
    @asleep = false
  end

  def play_with_pet
    @mood += 30
    @phrases << (p 'Вы поиграли со своим питомцем')
    pass_of_time
  end

  def toil
    @defecation = true
    @toilet = 100
    @phrases << (p 'Вы сводили питомца в туалет')
    pass_of_time
    @defecation = false
  end

  def bath
    @bathing = true
    @phrases << (p 'Вы покупали своего питомца')
    @purity = 100
    pass_of_time
    @bathing = false
  end

  def toss
    @mood += 15
    @phrases << (p 'Вы подбрасываете питомца')
    pass_of_time
  end

  def heal
    @health += 5
    @phrases << (p 'Вы даете питомцу витамины')
    pass_of_time
  end

  def sweets
    @eating = true
    @bellyful += 20
    @phrases << (p 'Вы угощаете питомца сладостями')
    pass_of_time
    @eating = false
  end

  def rock
    @asleep = true
    @phrases << (p 'Вы укачиваете питомца')
    pass_of_time
    @asleep = false
  end

  def watch
    rand = rand(1..4)
    case rand
    when 1
      @peppiness += 15
      @phrases << (p 'Питомец пригрелся на солнышке')
    when 2
      @bellyful += 15
      @toilet -= 30
      @phrases << (p 'Питомец нашел и съел неспелые ягоды, это может привести к диарее')
    when 3
      @mood += 15
      @phrases << (p 'Питомец бегает за воробьем')
    when 4
      @purity -= 20
      @phrases << (p 'Питомец прыгает по лужам')
    end
    pass_of_time
  end

  private

  def pass_of_time
    if @asleep
      @peppiness += 25
      if @peppiness >= 100
        @peppiness = 100
        @phrases << (p 'Питомец просыпается выспавшийся')
        @asleep = false
      end
    else
      @peppiness -= rand(5..15)
      @peppiness = 0 if @peppiness.negative?
      if @peppiness.zero?
        @health -= rand(5..15)
        @mood -= 10
        @phrases << (p 'От усталости Ваш питомец уснул на ходу и упал ударившись головой')
        # return @phrases << (p 'Ваш питомец получил травму головы') if @health <= 0
      elsif @peppiness <= 30
        @phrases << (p 'Глаза начинают слипаться')
      end
    end

    unless @defecation
      @toilet -= 10
      if @toilet <= 0
        @mood -= 10
        @purity -= 20
        @toilet = 100
        @phrases << (p 'Упс, питомец обделался')
      elsif @toilet <= 30
        @phrases << (p 'Ой, кажется питомец хочет в туалет')
      end
    end

    unless @bathing
      @purity -= 5
      @purity = 0 if @purity.negative?
      if @purity.zero?
        @mood -= 10
        @phrases << (p 'Ваш питомец весь в грязи, помойте его скорее!!!')
      elsif @purity <= 20
        @mood -= 5
        @phrases << (p 'Жуть какой грязный, пора мыться')
      elsif @purity <= 50
        @phrases << (p 'Уфф, замазался немного')
      end
    end

    if @eating
      @bellyful = 100 if @bellyful > 100
    else
      @bellyful -= rand(5..15)
      @bellyful = 0 if @bellyful.negative?
      if @bellyful.zero?
        @phrases << (p 'Ваш питомец мучается от голода')
        @health -= 5
        # if @health <= 0
        #   @phrases << (p 'Длительное голодание не приводит ни к чему хорошему')
        # end
      elsif @bellyful <= 30
        @mood -= 5
        @phrases << (p 'В животе урчит')
      end
    end

    @mood = 100 if @mood > 100
    @mood = 0 if @mood.negative?
    if @mood <= 0
      if @asleep
        @asleep = false
        @phrases.clear << (p 'Птомец просыпается в тревоге')
      end
      @phrases << (p 'Ваш питомец очень расстроен, он ушел из дома...')
      if rand(0..2).positive?
        @mood = 30
        @phrases << (p '...Но вернулся, спустя несколько часов')
      else
        @emoji = '&#127748;'
        @phrases << (p '...навсегда')
      end
    end
    @stats = [@health, @bellyful, @peppiness, @mood, @purity, @toilet]

    @emoji = if @stats.any? { |e| e <= 0 }
               '&#128546;'
             elsif @stats.any? { |e| e < 30 }
               '&#128532;'
             elsif @stats.any? { |e| e < 50 }
               '&#128528;'
             else
               '&#128515;'
             end

    return unless @health <= 0

    @emoji = '☠'
    @health = 0
    @phrases.clear << (p 'Ваш питомец умер')
  end
end
