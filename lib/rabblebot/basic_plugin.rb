# inherit from this if you're building a plugin. It sets up your brain, the yaml config, and gives you a convenience
# wrapper for CRUDing the brain
class BasicPlugin
  attr_accessor :bot, :brain, :config
  def initialize(bot, config)
    @brain = PStore.new("brains/#{self.class.to_s.downcase.split('::').last}.pstore")
    @bot = bot
    @config = config
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
