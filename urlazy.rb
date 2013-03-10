#!/usr/bin/env ruby

require 'yaml'
require 'socket'
require 'json'
require 'uri'
require 'ipaddr'

MULTICAST_ADDR = '239.255.41.1';
MULTICAST_PORT = 4111;

module URLazy
    class Listener
        def initialize(content_path, addr = MULTICAST_ADDR, port = MULTICAST_PORT)
            @path = content_path
            @addr = addr
            @port = port
            @host = Socket.gethostname
            ipaddr = Socket.ip_address_list.detect{|intf| intf.ipv4? && !intf.ipv4_loopback? \
                && !intf.ipv4_multicast? && !intf.ipv4_private?}
            ipaddr = Socket.ip_address_list.detect{|intf| intf.ipv4? && !intf.ipv4_loopback? \
                && !intf.ipv4_multicast? } if ipaddr.nil?
            @my_ipv4 = ipaddr.ip_address unless ipaddr.nil?
        end

        def loop
            ip = IPAddr.new(@addr).hton + IPAddr.new('0.0.0.0').hton
            sock = UDPSocket.new(Socket::AF_INET)
            sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_LOOP, [1].pack('i'))
            sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
            sock.bind('', @port)
            while true
                begin
                    mesg, sender = sock.recvfrom_nonblock(0)
                    next if sender.nil?
                    addr = sender[3]
                    port = sender[1]
                    puts "Query from #{addr}:#{port}"
                    send_response(sock, addr, port)
                rescue IO::WaitReadable
                    IO.select([sock])
                    retry
                end
            end
        end

        private
        def process_url(url)
            uri = URI.parse(url)
            if @my_ipv4 && uri.host == '.'
                uri.host = @my_ipv4
                return uri.to_s
            end
            return url
        rescue URI::InvalidURIError
            return url
        end

        def send_response(sock, addr, port)
            content = YAML::load_file(@path)
            content.each {|k,v| content[k] = process_url(v)}
            payload = JSON.generate({
                host: @host,
                content: content
            })
            sock.send(payload, 0, MULTICAST_ADDR, port)
        end
    end
end

content_path = ARGV[0] || File.dirname(__FILE__) + '/content.yaml'
listener = URLazy::Listener.new(content_path)
listener.loop

