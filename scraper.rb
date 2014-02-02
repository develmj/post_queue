require 'rubygems'
require 'snooby'
require 'twitter'

WORKINGDIR = "/home/mj/bgscripts/post_queue/"
BADSITES = WORKINGDIR + "adulturls"
BADWORDS = WORKINGDIR + "badwords"
OLDPOSTS = WORKINGDIR + "old_posts"
POSTQUEUE = WORKINGDIR + "firequeue"
SUBREDDITS = ["technology"]
AVOIDLINKS = ["reddit.com"]
AVOIDWORDS = []
TWITTER_CONSUMER_KEY = 
TWITTER_CONSUMER_SECRET = 
TWITTER_ACCESS_TOKEN = 
TWITTER_ACCESS_TOKEN_SECRET = 

#Set global twitter client
$tw_client = nil

def initiate_twitter_client
  $tw_client = Twitter::REST::Client.new({
                                           :consumer_key => TWITTER_CONSUMER_KEY,
                                           :consumer_secret => TWITTER_CONSUMER_SECRET,
                                           :access_token => TWITTER_ACCESS_TOKEN,
                                           :access_token_secret => TWITTER_ACCESS_TOKEN_SECRET
                                         })
end

def format_post(title,url)
  post = ""
  post = "#{title} - #{url}" if title.is_a?(String) and url.is_a?(String)
  return post if post.length > 0 and post.length <= 140
  return nil
end

def fire_to_twitter(title,url)
  if $tw_client
    post = format_post(title,url)
    $tw_client.update(post) if post.is_a?(String)
  end
end

def abandon_link?(link)
  badsites = []
  badsites = File.read(BADSITES).split("\n").uniq if File.exists?(BADSITES)
  re = Regexp.union(AVOIDLINKS+badsites)
  return nil if link.match(re)
  return true
end

def abandon_title?(title)
  badwrods = []
  badwords = File.read(BADWORDS).split("\n").uniq if File.exists?(BADWORDS)
  re = Regexp.union(AVOIDWORDS+badwords)
  return nil if title.match(re)
  return true
end

def get_new_posts
  collector = []
  reddit = Snooby::Client.new
  SUBREDDITS.each{|subreddit|
    posts = reddit.subreddit(subreddit).posts
    if posts.is_a?(Array)
      posts.each{|post|
        collector << [post.title,post.url] if (abandon_link?(post.url) and abandon_title?(post.title))
      }
    end
  }
  return collector
end

def filter_out_old_posts(old_posts,new_posts)
  old_title_map = old_posts.map{|x| x[0]}.compact
  new_title_map = new_posts.map{|x| x[0]}.compact
  return new_title_map - old_title_map
end

def get_old_posts
  if File.exist?(OLDPOSTS)
    f = File.read(OLDPOSTS)
    begin
      old_posts = Marsha.load(f)
      return old_posts if old_posts.is_a?(Array)
    rescue Exception => e
      return []
    end
  else
    return []
  end
end

def write_to_post_queue
  new_posts = get_new_posts
  old_posts = get_old_posts
  to_be_posted = filter_out_old_posts(old_posts,new_posts)
end
