What is this?

URLazy is an app for developers and testers who hate typing URLs into mobile "keyboards". It finds collections of URLs on your local network and lets you open them in the mobile browser with a single tap. It includes a Ruby script and a set of native apps for iOS, Android, and WP 7.5 & 8. Blackberry may come later.

How does it work?

You announce URLs you're interested in by running a Ruby script on your workstation, VM or local server. It waits for queries and then serves up a collection of URLs from a YAML file on demand. When you launch the app on your device, a query is sent out via multicast UDP. The Ruby script answers this with a multicast response and the app displays your list of URLs and any other collections it finds. Just tap on one and off you go.

If you change your list of URLs, just save the file and hit refresh on your device. An instance of the script could be run as a service on a local server to provide easy access to test URLs for your projects.

URLazy is all about ZERO CONFIGURATION. Using multicast allows it to find data sources on your LAN (or WAN if company routers are configured to support it) without giving it any info. You should be able to pick up a fresh device and load your projects without typing a thing.

Why do this? Why not use...

...bookmarks? Bookmarks are great until you use a bunch of shared devices for testing, and, like with a box of chocolates, you never know what you're gonna get. Also, you still have to enter the URLs at least once and then hope they don't change. Workstations on DHCP change IPs all the time, and projects move through different environments as they go through their life-cycle. Editing a URL on a mobile device is almost worse than entering it in the first place.
...a central index page? It still has to be updated by somebody, and good luck accessing it if you take your work home. URLazy is portable, so it works just as well on your home network. A central index page also won't reflect your workstation's IP at the time.

On that note, If my workstation's IP changes, will I have to update my URL list?

Nope. Use URLs in the format: http://./path/to/project/ and URLazy will automatically fill in the IP. If you take your laptop home or otherwise get a new IP, your device will still use the right URLs.

How do I run the server?

Just edit the content.yaml file with your desired URLs and then execute urlazy.rb. Your mobile devices should now find the URLs you have published on your local network.

Everything's set up, why don't I see any URLs?

UDP is a lossy protocol, so try hitting refresh a time or two. Every once a while, a packet will be dropped. This is particularly true on iPhone devices that appear to put the network into a "passive" mode that can ignore some traffic. If you still see nothing, ask for help running tcpdump to troubleshoot.

Many Windows 8 phones were released with a broken network stack. I've had good luck fixing this with firmware updates, especially on Nokia Lumia devices.

Finally, make sure the device is connected to the LAN you work from, not a guest network.

Requirements:
Ruby 1.9+ (gems: json, yaml)
iOS 5+ or Android 2.3.3+ or Windows Phone 7.5+
