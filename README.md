What is this?
-------------

URLazy is an app for developers and testers who hate typing URLs into mobile keyboards, especially when working with many devices. It finds collections of URLs on your local network and lets you open them in the mobile browser with a single tap.

Where do I get the GUI servers?
-------------------------------
OSX: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.dmg

Windows: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.msi 

How does it work?
-----------------

You announce URLs you're interested in by running a server on your workstation, VM or local server. It waits for queries and then serves up a collection of URLs on demand. When you launch the app on your device, a query is sent out via multicast UDP. The server answers this with a multicast response and the app displays your list of URLs and any other collections it finds. Just tap on one and off you go.

URLazy is all about ZERO CONFIGURATION. Using multicast allows it to find data sources on your LAN (or WAN if company routers are configured to support it) without giving it any info. You should be able to pick up a fresh device and load your projects without typing a thing.

The server comes in several flavors:

1. A Ruby script, recommended for running a persistent server on OSX or Linux. The script is available in the github repository. It requires Ruby 1.9.3+ and the 'json' and 'yaml' gems.

2. A GUI app for the Mac. The installer may be downloaded here: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.dmg

3. A GUI app for Windows. The installer may be downloaded here: https://s3-us-west-2.amazonaws.com/urlazy/urlazy-1.0.0.msi 

Why do this? Why not use...
---------------------------

...bookmarks? Bookmarks are great until you use a bunch of shared devices for testing, and, like with a box of chocolates, you never know what you're gonna get. Also, you still have to enter the URLs at least once and then hope they don't change. Workstations on DHCP change IPs all the time, and projects move through different environments as they go through their life-cycle. Editing a URL on a mobile device is almost worse than entering it in the first place.

...a central index page? It still has to be updated by somebody, and good luck accessing it if you take your work home. URLazy is portable, so it works just as well on your home network. A central index page also won't reflect your workstation's IP at the time.

On that note, If my workstation's IP changes, will I have to update my URL list?
--------------------------------------------------------------------------------

Nope. Use URLs in the format: http://localhost/path/to/project/ and URLazy will automatically fill in the IP. If you take your laptop home or otherwise get a new IP, your device will still use the right URLs.

How do I use the Ruby script?
-----------------------------
Just edit content.yaml and run the script. You may also edit content.yaml while the script is already running. For those who know Ruby, the script is easily extensible, so you could pull links from some other data source, if desired.

Everything's set up, why don't I see any URLs?
----------------------------------------------

UDP is a lossy protocol, so try hitting refresh a time or two. Every once in a while, a packet will be dropped. Your network administrator can use tcpdump or a similar tool to diagnose problems. On very rare occasions, some LAN equipment does not handle multicast properly.

Some devices are known to have a problematic network stack. If you have trouble, please ensure that you have installed the latest software updates on your device.

Finally, make sure the device is connected to the LAN you work from, not a guest network.
