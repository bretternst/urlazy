What is this?
-------------

URLazy is an app for developers and testers who hate typing URLs into mobile keyboards, especially when working with many devices. It finds collections of URLs on your local network and lets you open them in the mobile browser with a single tap.

Update (3/12/2013)
------------------
GUI server apps are now available for OSX and Windows.

OSX: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.pkg

Windows: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.msi 

How does it work?
-----------------

You announce URLs you're interested in by running a server on your workstation, VM or local server. It waits for queries and then serves up a collection of URLs from a YAML file on demand. When you launch the app on your device, a query is sent out via multicast UDP. The Ruby script answers this with a multicast response and the app displays your list of URLs and any other collections it finds. Just tap on one and off you go.

If you change your list of URLs, just save the file and hit refresh on your device. An instance of the script could be run as a service on a local server to provide easy access to test URLs for all the developers, PMs and testers on your project.

URLazy is all about ZERO CONFIGURATION. Using multicast allows it to find data sources on your LAN (or WAN if company routers are configured to support it) without giving it any info. You should be able to pick up a fresh device and load your projects without typing a thing.

How do I set up the server on OSX or Linux?
-------------------------------------------

If you are running OSX or Linux, a Ruby script is provided to publish your links.

Just execute the urlazy.rb Ruby script on any Mac OSX or Linux environment. If you need to install Ruby on your Mac, I recommend the RailsInstaller bundle found here: http://railsinstaller.org/

The script requires Ruby 1.9.3 or greater as well as the 'json' and 'yaml' modules. If these modules are not installed, you may install them by running "gem install yaml" and "gem install json".

To define the URLs you would like to publish on your network, just edit content.yaml. The file format is extremely simple and some sample URLs are provided to get you started. You may edit content.yaml while the server is running.

How do I set up the server on Windows?
--------------------------------------
Download the server installer from https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.msi and run it. Whenever the application is running, your device should find your collection of links. You can edit the links right in the application, and they will be saved when you close it.

Why do this? Why not use...
---------------------------

...bookmarks? Bookmarks are great until you use a bunch of shared devices for testing, and, like with a box of chocolates, you never know what you're gonna get. Also, you still have to enter the URLs at least once and then hope they don't change. Workstations on DHCP change IPs all the time, and projects move through different environments as they go through their life-cycle. Editing a URL on a mobile device is almost worse than entering it in the first place.
...a central index page? It still has to be updated by somebody, and good luck accessing it if you take your work home. URLazy is portable, so it works just as well on your home network. A central index page also won't reflect your workstation's IP at the time.

On that note, If my workstation's IP changes, will I have to update my URL list?

Nope. Use URLs in the format: http://localhost/path/to/project/ and URLazy will automatically fill in the IP. If you take your laptop home or otherwise get a new IP, your device will still use the right URLs.

Everything's set up, why don't I see any URLs?
----------------------------------------------

UDP is a lossy protocol, so try hitting refresh a time or two. Every once in a while, a packet will be dropped. This is particularly true on iPhone devices that appear to put the network into a "passive" mode that can ignore some traffic. If you still see nothing, ask for help running tcpdump to troubleshoot.

Some non-Apple devices may require a firmware update if you are not seeing any results.

Finally, make sure the device is connected to the LAN you work from, not a guest network.
