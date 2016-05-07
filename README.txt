This is a simple little karmabot. I've never wrote a discord bot before!

How to make this vr00m:
-1. have rvm <https://rvm.io/> installed and working
-1b. have bundler <http://bundler.io/> installed and working
0. run a close-enough-to-linux OS
1. Visit this page and get a developer account https://discordapp.com/developers/applications/me
2. `export DISCORD_TOKEN="the token you got on that page under 'app bot user'"`
3. `export DISCORD_APP_ID='the client/application id you got on that page'`
4. `bundle install --without nerds`
5. `bundle exec karmabot.rb`
6. look for the line that says "My oauth authroization URL is <thing>
6a. click that link as hard as you can
6b. click 'hell yeah i want this app to get at my servers'
7. You: @tom++
8. KarmaBot: @tom's karma increased to -887276834
