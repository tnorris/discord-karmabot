RSpec.describe RabbleBot do
  before(:each) do
    @bot_invite_url = "https://lol.invalid/"
    bot_double = instance_double 'Discordrb::Bot'
    allow(bot_double).to receive(:info).and_return(nil)
    allow(bot_double).to receive(:debug).and_return(nil)
    allow(bot_double).to receive(:message).and_return(nil)
    allow(bot_double).to receive(:invite_url).and_return(@bot_invite_url)
    allow_any_instance_of(RabbleBot).to receive(:my_bot).and_return(bot_double)
  end

  it 'can parse a configuration file' do
    rabble_bot = RabbleBot.new
    expect{rabble_bot.load_config}.to_not raise_error
  end

  it 'can create a new object with the Discordrb::Bot mock' do
    expect{RabbleBot.new}.to_not raise_error
  end

  it 'loads plugins' do
    expect(RabbleBot::RabbleBotPlugin).to receive(:require_plugins)

    r = RabbleBot.new
    r.load_plugins
  end

  it 'spits out an oauth url during bootstrap' do
    expect(STDERR).to receive(:puts).with(/My oauth authorization URL is: #{@bot_invite_url}/).and_return(nil)
    r = RabbleBot.new
    r.bootstrap
  end
end
