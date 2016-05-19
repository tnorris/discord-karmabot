This is a simple little discord bot. I've never wrote a discord bot before! It can do plugins!

# Pre requisites
1. run linux or macos, maybe in a VM if you're on windows?
2. install RVM <https://rvm.io/>
3. install bundler <http://bundler.io>
4. Visit this page and get a developer account https://discordapp.com/developers/applications/me

# Setup
You can set the `DISCORD_TOKEN` and `DISCORD_APP_ID` environment variables, or you can add them to `brains/config.yml`

# Installation
1. `git clone https://github.com/tnorris/rabblebot.git`
2. `cd rabblebot`
3. `bundle install --without nerds`
4. `cp brains/config{.example,}.yml` and edit this file to fit your needs. `ENV_VAR`s will override the `DISCORD_TOKEN` and `DISCORD_APP_ID`
5. `bundle exec ruby ./exe/rabblebot`
6. look for the line that says "My oauth authroization URL is: <url>"
7. click that link as hard as you can
8. allow the app to use your server
9. You: @tom++
10. RabbleBot: @tom's karma increased to -887276834


TODO:
- Stop a crashing plugin from taking down the whole bot
