Furby
=====

A simplified(currently 67SLOC!) [rawdog]() clone written in Ruby, using ERB templates.

I decided to implement this because rawdog was lacking templating support(it only supports styling via css), and there wasn't any alternative for static feed readers. 

It simply reads feeds urls from "feeds" file, fetches them via amazing [feedzirra]() gem, merges them and spits out via a customizable ERB template.  
  
It supports parallel fetching of feeds, also it can limit articles by count or filter them by time.   
  
Installation & Usage
--------------------

Installation is done via bundler, just a `bundle install` command should be sufficient:

    git clone git@github.com:utdemir/furby.git
    cd furby
    bundle install
  
Currently, configuration is done via modifying the source(`furby.rb`), although it is pretty simple:
    
    FEEDS = "./feeds"
    TEMPLATE = "./template.erb"
    OUTPUT = "./output.html"
    
    THREAD_COUNT = 2
    MAX_ITEMS = 100
    SINCE = DateTime.now - 2 # show for last two days
    
[feed file] is just feed url's on separate lines and [template] is a ERB template, defaults are explanatory.  

Credits
-------

* [feedzirra] gem does nearly all the work, `furby` just takes the results and sends to ERB template.
    
* Default template is written according to [rawdog]()'s default template and `style.css` is shamelessly stolen from it.
  
    
[rawdog]: http://offog.org/code/rawdog/
[feedzirra]: https://github.com/pauldix/feedzirra
