#!/usr/bin/ruby

require 'erb'
require 'date'
require 'optparse'

require 'feedzirra'

VERSION = :devel

parser = OptionParser.new do |opts|
  opts.banner = "Usage: furby.rb [-c N] [-d N] [-t N] feeds template output"
  opts.on("-c", "--count N", Integer, "Maximum article count") do |c|
    $max_items = c
  end
  opts.on("-t", "--threads N", Integer, "Maximum parallel requests when fetching feeds [3]") do |t|
    $threads = t
  end
  opts.on("-d", "--days N", Integer, "Don't show articles older than N days") do |n|
    $since = DateTime.now - n
  end
end
parser.parse!

if ARGV.length != 3 
  puts parser
  exit
end

FEEDS, TEMPLATE, OUTPUT = ARGV

urls = File.readlines FEEDS
urls.map! { |i| i.gsub(/#.*$/, "").strip }
urls.select! { |i| not i.empty? }

feeds = []
threads = []
errors = {}

urls.each_slice((urls.size / ($thread_count or 3).to_f).ceil) do |s|
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
  feed.entries.take_while { |e| $since ? e.published >= $since : true }.each do |entry| 
    entry[:feed] = feed
    entry.sanitize! 
    entries << entry
  end
end

entries.sort_by! { |i| i.published or Time.now }
entries.reverse!

entries.slice! $max_items..entries.size if $max_items

template_string = File.read TEMPLATE
template = ERB.new template_string

class AccessController
  def initialize(feeds, entries, errors)
    @feeds = feeds
    @entries = entries
    @errors = errors
    @version = VERSION
  end
  def get_binding 
    binding
  end
end

controller = AccessController.new(feeds, entries, errors)
result = template.result controller.get_binding
File.open(OUTPUT, 'w') { |file| file.write result }
