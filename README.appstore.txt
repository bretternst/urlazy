URLazy is a small utility for mobile web developers and testers designed to address one common complaint. It eases the pain of entering long URLs into a bunch of test devices by finding collections of URLs on the local network and allowing you to open them with a single tap.

An accompanying Ruby script can publish a set of links from your workstation or local development server. URLazy finds this list with no configuration required, provided you are connected to your network via Wi-Fi. This makes it super easy to test your projects on real devices without manually setting up bookmarks or entering URLs.

This is a better alternative to bookmarks or centralized index pages because new devices require no set-up and you don't have to edit URLs every time your environment changes--or if you take your work home.

URLazy uses multicast UDP to find collections of links. If your network administrator enables it, this can even work across a corporate WAN. The server is very simple and straightforward, making it easy to modify or re-implement as you desire.

The server script may be downloaded from the GitHub repo here: http://github.com/bretternst/urlazy
