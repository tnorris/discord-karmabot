This is a simple little discord bot. I've never wrote a discord bot before! It can do plugins!

# Pre requisites
1. run linux or macos, maybe in a VM if you're on windows?
2. install RVM <https://rvm.io/>
3. install bundler <http://bundler.io>
4. Visit this page and get a developer account https://discordapp.com/developers/applications/me

# Setup
You can set the `DISCORD_TOKEN` and `DISCORD_APP_ID` environmetn variables, or you can add them to `brains/config.yml`

# Installation
1. `git clone https://github.com/tnorris/rabblebot.git`
2. `cd rabblebot`
3. `bundle install --without nerds`
4. `bundle exec ruby ./exe/rabblebot`
5. look for the line that says "My oauth authroization URL is: <url>"
6. click that link as hard as you can
6. allow the app to use your server
7. You: @tom++
8. RabbleBot: @tom's karma increased to -887276834


TODO:
- Tests?
