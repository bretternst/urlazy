#!/usr/bin/env ruby

require 'socket'
require 'json'
require 'ipaddr'

MULTICAST_ADDR = '239.255.41.1'
MULTICAST_PORT = 4111

ip = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new('0.0.0.0').hton
sock = UDPSocket.new(Socket::AF_INET)
sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
sock.send('', 0, MULTICAST_ADDR, MULTICAST_PORT)

IO.select([sock])
mesg, sender = sock.recvfrom_nonblock(65536)
payload = JSON.parse(mesg)
puts "host = #{payload['host']}"
payload['content'].each {|k,v|
    puts "  #{k} = #{v}"
}
