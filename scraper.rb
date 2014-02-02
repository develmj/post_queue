require 'rubygems'
require 'snooby'

WORKINGDIR = "/home/mj/torture/post_queue/"
BADSITES = WORKINGDIR + "adulturls"
BADWORDS = WORKINGDIR + "badwords"
OLDPOSTS = WORKINGDIR + "old_posts"
POSTQUEUE = WORKINGDIR + "firequeue"
SUBREDDITS = ["technology"]
AVOIDLINKS = ["reddit.com"]
AVOIDWORDS = ["IAMA"]

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
  current_posts = []
  if File.exist?(POSTQUEUE)
    f = File.read(POSTQUEUE)
    current_posts = Marshal.load(f)
  end
  old_post_hash = {}
  new_post_hash = {}
  old_posts.each{|x| old_post_hash[x[0]] = x[1]}
  new_posts.each{|x| new_post_hash[x[0]] = x[1]}
  current_posts.each{|x| new_post_hash[x[0]] = x[1]}
  old_title_map = old_posts.map{|x| x[0]}.compact
  new_title_map = new_posts.map{|x| x[0]}.compact
  return (new_title_map - old_title_map).map{|x| [x,new_post_hash[x]]}
end

def get_old_posts
  if File.exist?(OLDPOSTS)
    f = File.read(OLDPOSTS)
    begin
      old_posts = Marshal.load(f)
      return old_posts if old_posts.is_a?(Array)
      return []
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
  f = File.open(POSTQUEUE,"w")
  f.write(Marshal.dump(to_be_posted))
  f.close
end

write_to_post_queue
