class BasicPlugin
  attr_accessor :bot, :brain
  def initialize(bot)
    @brain = PStore.new("brains/#{self.class.to_s.downcase.split('::').last}.pstore")
    @bot = bot
  end

  def update(key, data)
    @brain.transaction do
      @brain[key] = data
      @brain[key]
    end
  end

  def lookup(key)
    @brain.transaction do
      @brain[key]
    end
  end
end