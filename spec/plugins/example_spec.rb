require_relative('../../lib/rabblebot/basic_plugin')
require_relative('../../lib/rabblebot/plugins/example')

RSpec.describe RabbleBot::RabbleBotPlugin::Example do
  before(:each) do
    @bot_double = instance_double 'Discordrb::Bot'
    @config_double = instance_double 'Hash'
    allow(@bot_double).to receive(:info).and_return(nil)
    allow(@bot_double).to receive(:debug).and_return(nil)
    allow(@bot_double).to receive(:message).and_return(nil)
    allow(@bot_double).to receive(:invite_url).and_return(@bot_invite_url)
    allow_any_instance_of(RabbleBot).to receive(:my_bot).and_return(@bot_double)
  end

  it 'adds a query_handler on initialization' do
    expect_any_instance_of(RabbleBot::RabbleBotPlugin::Example).to receive(:add_query_handler)
    RabbleBot::RabbleBotPlugin::Example.new(@bot_double, @config_double)
  end
end
