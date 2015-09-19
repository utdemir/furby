Furby
=====

[![Dependency Status](https://gemnasium.com/utdemir/furby.png)](https://gemnasium.com/utdemir/furby)

A simplified (currently 67SLOC!) [rawdog][] clone written in Ruby, using ERB templates.

I decided to implement this because rawdog was lacking templating support (it only supports styling via css), and there weren't any other alternatives for static feed readers. 

It simply reads feed urls from "feeds" file, fetches them via amazing [feedzirra][] gem, merges them and spits out via a customizable ERB template. I also wrote a nice theme based on [Bootstrap][]. 
  
It supports parallel fetching of feeds. Also, it can limit articles by count or filter them by time.   

Demo
----
Example: http://utdemir.github.io/furby
  
Installation & Usage
--------------------

Installation is done via bundler, a simple `bundle install` command should be sufficient:

    git clone https://github.com/utdemir/furby.git
    cd furby
    bundle install
  
Currently, configuration is done via command line arguments:
    
    $ ./furby.rb 
    Usage: furby.rb [-c N] [-d N] [-t N] feeds template output
       -c, --count N                    Maximum article count
       -t, --threads N                  Maximum parallel requests when fetching feeds [3]
       -d, --days N                     Don't show articles older than N days


`feeds`, `template` and `output` corresponds to feed url list, the erb template and the output files respectively. To use defaults;

    ./furby.rb feeds template.erb output.html
    
[feed file] is just feed url's on separate lines and [template] is a ERB template, defaults are explanatory.  

Credits
-------

* [feedzirra] gem does nearly all the work, `furby` just takes the results and sends to ERB template.
    
* Using [Bootstrap][] front-end framework now.
  
    
[rawdog]: http://offog.org/code/rawdog/
[feedzirra]: https://github.com/pauldix/feedzirra
[bootstrap]: http://getbootstrap.com/
