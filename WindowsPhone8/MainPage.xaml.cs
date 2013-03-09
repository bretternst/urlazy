using Microsoft.Phone.Controls;
using Microsoft.Phone.Net.NetworkInformation;
using Microsoft.Phone.Tasks;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace URLazy
{
    public class GroupList<T> : List<T>
    {
        public GroupList(string key, IEnumerable<T> other)
            : base(other)
        {
            this.Key = key;
        }

        public string Key { get; private set; }
    }

    public partial class MainPage : PhoneApplicationPage
    {
        private static readonly IPAddress MulticastIP = IPAddress.Parse("239.255.41.1");
        private const int ServerPort = 4111;
        private const int TimeoutDelay = 3000;
        private const int TimeoutRetries = 3;

        private ObservableCollection<GroupList<KeyValuePair<string, string>>> _listData;
        private UdpAnySourceMulticastClient _socket;
        private byte[] _buf;
        private Timer _timer;
        private int _timeouts;

        public MainPage()
        {
            InitializeComponent();
            _listData = new ObservableCollection<GroupList<KeyValuePair<string, string>>>();
            _buf = new byte[65536];
            btnRefresh.Click += btnRefresh_Click;
            list.SelectionChanged += list_SelectionChanged;
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            if (!DeviceNetworkInformation.IsWiFiEnabled || !DeviceNetworkInformation.IsNetworkAvailable)
            {
                this.OnNoNetwork();
                return;
            }

            _listData.Clear();
            this.Start();
        }

        private void Start()
        {
            this.Stop();

            progress.IsVisible = true;
            _timeouts = 0;
            _socket = new UdpAnySourceMulticastClient(MulticastIP, 0);
            try
            {
                _socket.BeginJoinGroup((ar) =>
                {
                    _socket.EndJoinGroup(ar);
                    _socket.ReceiveBufferSize = 65536;
                    _timer = new Timer(this.OnTimeout, null, TimeoutDelay, TimeoutDelay);
                    this.Send();
                }, null);
            }
            catch
            {
                this.OnNoNetwork();
            }
        }

        private void Stop()
        {
            if (_timer != null)
            {
                _timer.Dispose();
                _timer = null;
            }
            if (_socket != null)
            {
                _socket.Dispose();
            }
            progress.IsVisible = false;
        }

        private void Send()
        {
            byte[] buf = Encoding.UTF8.GetBytes("query");
            _socket.BeginSendTo(buf, 0, buf.Length, new IPEndPoint(MulticastIP, ServerPort), (ar) =>
            {
                _socket.EndSendTo(ar);
                _socket.BeginReceiveFromGroup(_buf, 0, _buf.Length, socket_Received, null);
            }, null);
        }

        private void OnTimeout(object o)
        {
            if (_timeouts++ == TimeoutRetries)
            {
                Dispatcher.BeginInvoke((Action)(() =>
                {
                    this.Stop();
                    if (_listData.Count == 0)
                    {
                        MessageBox.Show("No collections found. Make sure a URLazy server is running on your local network.");
                    }
                }));
            }
            else
            {
                this.Send();
            }
        }

        private void socket_Received(IAsyncResult ar)
        {
            IPEndPoint src;
            try
            {
                int count = _socket.EndReceiveFromGroup(ar, out src);
                var payload = Encoding.UTF8.GetString(_buf, 0, count);
                _socket.BeginReceiveFromGroup(_buf, 0, _buf.Length, socket_Received, null);
                Dispatcher.BeginInvoke(new Action<string>(OnReceived), payload);
            }
            catch (SocketException ex)
            {
                return;
            }
        }

        private void OnReceived(string payload)
        {
            var root = JObject.Parse(payload);
            var host = (string)root["host"];
            var pairs = new GroupList<KeyValuePair<string, string>>(host,
                root["content"].OfType<JProperty>().Select(p => new KeyValuePair<string, string>(p.Name, (string)p.Value)));
            pairs.Sort((kvp1, kvp2) => string.Compare(kvp1.Key, kvp2.Key));
            for (int i = 0; i < _listData.Count; i++)
            {
                if (_listData[i].Key == host)
                    return;
            }
            _listData.Add(pairs);
            if (list.ItemsSource == null)
                list.ItemsSource = _listData;
            progress.IsVisible = false;
        }

        private void list_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (list.SelectedItem != null)
            {
                var item = (KeyValuePair<string, string>)list.SelectedItem;
                var task = new WebBrowserTask();
                task.Uri = new Uri(item.Value);
                task.Show();
            }
            list.SelectedItem = null;
        }

        void btnRefresh_Click(object sender, RoutedEventArgs e)
        {
            _listData.Clear();
            this.Start();
        }

        private void OnNoNetwork()
        {
            MessageBox.Show("This app requires a Wi-Fi connection.");
            throw new Exception("No network available.");
        }
    }
}
