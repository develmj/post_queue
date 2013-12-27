require 'rubygems'
require 'snooby'

SUBREDDITS = ["technology"]
AVOIDLINKS = ["reddit.com"]
AVOIDWORDS = ["?", "thank", "help", "pr0n", "porn", "adult", "sex", "xxx", "charity", "4some", "abduction", "abortion", "abuse", "acid", "addict", "addiction", "alcohol", "alcoholic", "analingus", "anus", "asshole", "beheading", "bimbo", "bisexual", "bitch", "blood", "bloody", "blow", "bottom", "breast", "breathplay", "bugger", "butt", "caca", "caning", "cannabis", "carnal", "cathouse", "choke", "choking", "cleavage", "cocaine", "cocksucker", "cocksucking", "coitus", "collar", "condom", "conspiracy", "copulation", "creampie", "cuckolding", "cuffs", "cumslut", "dick", "dirty", "dismemberment", "dom", "dominance", "dominant", "drugs", "d/s", "dyke", "edgeplay", "enema", "erection", "erotic", "erotica", "execution", "exhibitionism", "exotic", "facesit", "facial", "fanny", "femboi", "femboy", "fetish", "figging", "filthy", "fist", "flaccid", "flay", "flogger", "flogging", "fondle", "force", "forced", "foreplay", "fornication", "foursome", "freesex", "fucker", "fucks", "furry", "gag", "gaming", "gang bang", "gay", "genitalia", "glory hole", "golden shower", "gore", "gory", "groupsex", "hard on", "harlot", "hermaphrodite", "heroin", "hogtie", "homicide", "homosexual", "hooker", "humiliation", "illicit", "impaling", "impregnate", "incest", "intercourse", "interracial", "jack off", "jerk off", "kajira", "kidnap", "kink", "latex", "lesbian", "lick", "lolita", "love", "lsd", "lynch", "madam", "maim", "marijuana", "masturbate", "mate", "milf", "milking", "mistress", "motherfucker", "murder", "mutilation", "naked", "nasty", "naughty", "necrophilia", "nude", "nookie", "nymphomaniac", "obscene", "opium", "oral", "penises", "penetration", "perv", "pervert", "piss", "pornography", "pre-cum", "prick", "pubic", "queer", "quickie", "rimming", "rubber", "s&m", "screw", "semen", "sexual", "sexy", "shaft", "shibari", "sissy", "slaves", "smut", "sodomy", "spank", "spanking", "sperm", "spunk", "stab", "suck", "strangle", "strangling", "strip", "striptease", "submission", "succubus", "swallow", "testicles", "throatfucking", "tgirl", "t-girl", "tit", "titty", "topless", "torture", "tramp", "tranny", "transgender", "transsexual", "transvestite", "twink", "underage", "virgin", "vore", "watersports", "whip", "whipping", "whorehouse", "xcite", "xxxx", "young", "zindra", "zoophile", "zoophilia", "3some", "anal", "asphyxiation", "bdsm", "beastiality", "blowjob", "bondage", "boobs", "brothel", "bukkake", "callgirl", "cannibal", "cannibalism", "clit", "cock", "cum", "cunnilingus", "cunt", "deepthroat", "dildo", "dolcett", "dominatrix", "domme", "dungeon", "ejaculation", "escort", "facesitting", "fellatio", "femdom", "fisting", "fuck", "fucking", "gangbang", "gloryhole", "handjob", "hentai", "masochism", "masochist", "nympho", "orgy", "pee", "porno", "prostitute", "pussy", "rimjob", "sadism", "sadist", "sado", "scat", "slave", "snuff", "strapon", "stripper", "submissive", "swinger", "threesome", "throatfuck", "twat", "vibrator", "wank", "xrated", "yiff"]

def fire_to_twitter
end

def abandon_link?(link)
  re = Regexp.union(AVOIDLINKS)
  return nil if link.match(re)
  return true
end

def abandon_title?(title)
  re = Regexp.union(AVOIDWORDS.uniq)
  return nil if link.match(re)
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

def filter_out_old_posts
end

def check_aggregation
  new_posts = get_new_posts
  old_posts = get_old_posts
  to_be_posted = filter_out_old_posts(old_posts,new_posts)
  fire_to_twitter(to_be_posted)
end
