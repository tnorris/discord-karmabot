require_relative('../../lib/rabblebot/basic_plugin')
require_relative('../../lib/rabblebot/plugins/karma')

RSpec.describe RabbleBot::RabbleBotPlugin::Karma do
  before(:each) do
    @bot_double = instance_double 'Discordrb::Bot'
    @config_double = instance_double 'Hash'
    allow(@bot_double).to receive(:info).and_return(nil)
    allow(@bot_double).to receive(:debug).and_return(nil)
    allow(@bot_double).to receive(:message).and_return(nil)
    allow(@bot_double).to receive(:invite_url).and_return(@bot_invite_url)
    allow_any_instance_of(RabbleBot).to receive(:my_bot).and_return(@bot_double)
  end

  it 'adds the proper message handlers on initialization' do
    message_handlers = [:add_increment_handler,
                        :add_decrement_handler,
                        :add_help_handler,
                        :add_query_handler]
    message_handlers.each do |handler|
      expect_any_instance_of(RabbleBot::RabbleBotPlugin::Karma).to receive(handler)
    end

    RabbleBot::RabbleBotPlugin::Karma.new(@bot_double, @config_double)
  end

  it 'finds things to increment' do
    k = RabbleBot::RabbleBotPlugin::Karma.new(@bot_double, @config_double)
    expect(k.scan_increment('tom++ tom++ tom++')).to eq(%w(tom tom tom))
  end

  it 'finds things to decrement' do
    k = RabbleBot::RabbleBotPlugin::Karma.new(@bot_double, @config_double)
    expect(k.scan_decrement('tom-- tom-- tom--')).to eq(%w(tom tom tom))
  end

  it 'should give a snarky message if someone tries to self-give karma' do
    k = RabbleBot::RabbleBotPlugin::Karma.new(@bot_double, @config_double)
    author_id = '9999'
    thing = "<@#{author_id}>"
    expect(k.can_give_karma_to?(author_id, thing)).to eq(false)
  end

  it 'should let users give each other karma' do
    k = RabbleBot::RabbleBotPlugin::Karma.new(@bot_double, @config_double)
    author_id = '9292'
    thing = '<@9999>'
    expect(k.can_give_karma_to?(author_id, thing)).to eq(true)
  end
end
