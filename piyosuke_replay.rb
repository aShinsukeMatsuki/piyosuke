# -*- coding: utf-8 -*-
$LOAD_PATH.push('.')

require 'sqbot_keys'
require 'rubygems'
require 'twitter'
require 'google_spreadsheet'

if RUBY_VERSION < '1.9.0'
  class Array
    def choice
      at(rand(size))
    end
  end
end

START_LOW = 4
START_COL = 3
END_LOW = 129
tweets = []
answerlist = []

filehandle = open( "laststatus.txt" , "r")
laststatus = filehandle.gets.to_i
filehandle.close
lastnum = laststatus.to_i

session = GoogleSpreadsheet.login(USER, PASS)
ws = session.spreadsheet_by_url(URL).worksheets[0]

for i in START_LOW..END_LOW
  if ws[i, START_COL+2] == "1" then
    #DO NOT LIST TWEET
  else
    tweets.push(ws[i, START_COL])
  end
end

Twitter.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = OAUTH_TOEKN
  config.oauth_token_secret = OAUTH_TOEKN_SECRET
end

Twitter.mentions.each do |m|
  #puts m.id.to_s + ":" + m.user.screen_name  + m.text
  statid = m.id.to_i
  if lastnum < statid then
    lastnum = statid
  end
  next if laststatus >= statid
  if m.text[0..10] == "@SQuBOK_BOT"
    puts "HIT!"
    puts m.text
    tweets.each do |t|
      if t.index(m.text.delete("@SQuBOK_BOT ")) then
        answerlist.push(t)
      end
    end
    if answerlist.length > 0 then
      reply =  "@" + m.user.screen_name + " " + answerlist.choice
      if reply.split(//u).size > 140 then
        puts "DEBUG:140 char over!"
        if reply.index("http://") then
          puts "DEBUG:include url!"
          reply.slice!( reply.index("http://") - m.user.screen_name.split(//u).size * 4..reply.index("http://") -2)
          puts reply
          puts reply.split(//u).size.to_s
        else
          puts reply[0..139]
        end
      else
        puts reply
      end
    else
      puts "なかったピヨ… がんばって勉強するのでもう少し待っててピヨ！"
    end
  end
end

filehandle = File.open( "laststatus.txt" , "w")
filehandle.puts lastnum
filehandle.close

#Twitter.update(tweets[rand(tweets.size)])
