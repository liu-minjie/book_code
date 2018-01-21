require 'rubygems'

require 'mongo'
require 'twitter'

require 'config'

class TweetArchiver

  # Create a new instance of TweetArchiver
  # <start id="initialize" />  
  def initialize(tag)
    connection = Mongo::Connection.new
    db         = connection[DATABASE_NAME]
    @tweets    = db[COLLECTION_NAME]

    @tweets.create_index([['id', 1]], :unique => true)
    @tweets.create_index([['tags', 1], ['id', -1]])

    @tag = tag
    @tweets_found = 0
  end
  # <end id="initialize" />

  def update
    @tweets_found = 0
    puts "Starting Twitter search for '#{@tag}'..."
    save_tweets_for(@tag)
    print "#{@tweets_found} tweets saved.\n\n"
  end

  private

  # <start id="search" />  
  def save_tweets_for(term)
    Twitter::Search.new.containing(term).each do |tweet|
      @tweets_found  += 1
      tweet_with_tag = tweet.to_hash.merge!({"tags" => [term]})
      @tweets.save(tweet_with_tag)
    end
  end
  # <end id="search" />

end
