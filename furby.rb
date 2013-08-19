#!/usr/bin/ruby

require 'erb'
require 'date'

require 'feedzirra'

FEEDS = "./feeds"
TEMPLATE = "./template.erb"
OUTPUT = "./output.html"

THREAD_COUNT = 2
MAX_ITEMS = 100

# SINCE = DateTime.now - 7 # show just last week's items
SINCE = nil

urls = File.readlines FEEDS
urls.map! { |url| url.chomp }
urls.select! { |url| not url.empty? and not url =~ /^\s*#/ }

feeds = []
threads = []
errors = {}

urls.each_slice((urls.size / THREAD_COUNT.to_f).ceil) do |s|
  threads << Thread.new do
    (Feedzirra::Feed.fetch_and_parse s).each do |url, feed|
      if feed.kind_of? Fixnum 
        # on errors, feedzirra returns error code as a Fixnum
        errors[url] = feed 
      else 
        feeds << feed
      end
    end
  end
end
threads.each { |t| t.join }

entries = []
feeds.each do |feed| 
  feed.entries.take_while { |e| not SINCE or e.published >= SINCE }.each do |entry| 
    entry[:feed] = feed
    # entry.sanitize! # Not working currently: https://github.com/sparklemotion/nokogiri/issues/553
    entries << entry
  end
end

entries.sort_by! { |i| i.published }
entries.reverse!

entries.slice! MAX_ITEMS..entries.size

template_string = File.read TEMPLATE
template = ERB.new template_string

class AccessController
  def initialize(feeds, entries, errors)
    @feeds = feeds
    @entries = entries
    @errors = errors
  end
  def get_binding 
    binding
  end
end

controller = AccessController.new(feeds, entries, errors)
result = template.result controller.get_binding
File.open(OUTPUT, 'w') { |file| file.write result }
