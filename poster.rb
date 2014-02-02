require 'rubygems'
require 'twitter'
require 'yourls'

WORKINGDIR = "/home/mj/torture/post_queue/"
ARCHIVEDIR = "/home/mj/tweetfirearchive/"
POSTQUEUE = WORKINGDIR + "firequeue"
TEMPQUEUE = WORKINGDIR + "firequeue.tmp"
POSTARCHIVE = WORKINGDIR + "archive.txt"
TWITTER_CONSUMER_KEY = "NM3AGMdWNiD5c9YOSbJ2w"
TWITTER_CONSUMER_SECRET = "ebsMMNguFqjF95TyOPiU3tD8uhDNGqtdI0FJr7ykzo"
TWITTER_ACCESS_TOKEN = "1903878085-z5hOVB9HPNZLiYDjDCbbXOsqEcLK9ehFiTAYDKn"
TWITTER_ACCESS_TOKEN_SECRET = "UBaFQOBPKb5d4QpzPxEi7MuXkK1HQyCIPDd3fge0Os1BU"
YOURLS_TOKEN = "1e64a6c492"

#Set global twitter client
$tw_client = nil
$yourls_client = nil

def initiate_yourls
  $yourls_client = Yourls.new("http://bbug.in",YOURLS_TOKEN,{:offset => 19800})
end

def initiate_twitter_client
  $tw_client = Twitter::REST::Client.new({
                                           :consumer_key => TWITTER_CONSUMER_KEY,
                                           :consumer_secret => TWITTER_CONSUMER_SECRET,
                                           :access_token => TWITTER_ACCESS_TOKEN,
                                           :access_token_secret => TWITTER_ACCESS_TOKEN_SECRET
                                         })
end

def shorten_url(url,keyword = nil)
  if keyword
    url = $yourls_client.shorten(url,:keyword => keyword)
  else
    url = $yourls_client.shorten(url)
  end
  if url.is_a?(Yourls::Url)
    return url.short_url
  else
    return nil
  end
end

def format_post(title,url)
  return nil if title.to_s == "" or url.to_s == ""
  short_url = shorten_url(url)
  post = ""
  post = "#{title} - #{short_url}" if title.is_a?(String) and short_url.is_a?(String)
  return post if post.length > 0 and post.length <= 140
  return nil
end

def fire_to_twitter(title,url)
  begin
    if $tw_client
      post = format_post(title,url)
      $tw_client.update(post) if post.is_a?(String)
      return post
    end
    return nil
  rescue Exception => e
    puts e
    return nil
  end
end

def write_to_archive(tweet)
  f = File.open(POSTARCHIVE,"a+")
  f.write(tweet + "\n")
  f.close
end

def read_scraper_queue
  if File.exist?(POSTQUEUE)
    `cp #{POSTQUEUE} #{TEMPQUEUE}`
    f = File.read(TEMPQUEUE)
    post_queue = Marshal.load(f)
    if post_queue
      to_be_posted = post_queue.shift
      f = File.open(TEMPQUEUE,"w")
      f.write(Marshal.dump(post_queue))
      f.close
      `cp #{TEMPQUEUE} #{POSTQUEUE}`
      return to_be_posted
    else
      return nil
    end
  else
    return nil
  end
end

def send_tweet
  #initiate globals
  initiate_yourls
  initiate_twitter_client
  
  #First mechanism of tweet source
  scraper_post = read_scraper_queue
  ret = nil
  ret = fire_to_twitter(scraper_post[0],scraper_post[1]) if scraper_post
  write_to_archive(ret) if ret
end

send_tweet
