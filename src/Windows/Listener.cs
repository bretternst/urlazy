using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using Newtonsoft.Json;

namespace URLazyServer
{
    public class Listener : IDisposable
    {
        const string MulticastAddr = "239.255.41.1";
        const int ServerPort = 4111;

        IPAddress _myAddr;
        UdpClient _socket;
        Func<IDictionary<string, string>> _getContent;

        public Listener(Func<IDictionary<string,string>> getContent, string addr = MulticastAddr, int port = ServerPort)
        {
            _getContent = getContent;
            _myAddr = (from iface in NetworkInterface.GetAllNetworkInterfaces()
                       let ipprops = iface.GetIPProperties()
                       let ip = ipprops.UnicastAddresses.FirstOrDefault(ip => ip.DuplicateAddressDetectionState == DuplicateAddressDetectionState.Preferred && ip.AddressPreferredLifetime != UInt32.MaxValue)
                       where ip != null
                       select ip.Address).FirstOrDefault();
            _socket = new UdpClient(port);
            _socket.MulticastLoopback = false;
            _socket.JoinMulticastGroup(IPAddress.Parse(addr), _myAddr);
            _socket.BeginReceive(OnReceive, null);
        }

        private void OnReceive(IAsyncResult ar)
        {
            IPEndPoint ep = null;
            byte[] data = _socket.EndReceive(ar, ref ep);
            var payload = JsonConvert.SerializeObject(new
            {
                host = Environment.MachineName,
                content = _getContent()
            });
            var buf = Encoding.UTF8.GetBytes(payload);
            _socket.Send(buf, buf.Length, ep);
            _socket.BeginReceive(OnReceive, null);
        }

        public void Dispose()
        {
            _socket.Close();
        }
    }
}
