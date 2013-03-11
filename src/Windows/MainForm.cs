using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace URLazyServer
{
    public partial class MainForm : Form
    {
        BindingList<Entry> _entries;
        Listener _listener;
        IDictionary<string, string> _content;

        public MainForm()
        {
            InitializeComponent();

            _entries = new BindingList<Entry>();
        }

        private string ContentFilePath
        {
            get
            {
                return Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + @"\URlazy\content.txt";
            }
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            lblHostname.Text = "Hostname: " + Environment.MachineName;
            this.LoadContent();
            grdContent.DataSource = _entries;
            _entries.ListChanged += _entries_ListChanged;
            this.UpdateContent();
            try
            {
                _listener = new Listener(() => _content);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Unable to start server: " + ex.Message, "Error");
                Application.Exit();
                return;
            }
            lblYourIP.Text = "Your IP: " + _listener.LocalIPAddress.ToString();
        }

        void UpdateContent()
        {
            _content = _entries.Where(e => !string.IsNullOrEmpty(e.Name) && !string.IsNullOrEmpty(e.Url))
                .ToDictionary((e) => e.Name, (e) => e.Url);
        }

        void _entries_ListChanged(object sender, ListChangedEventArgs e)
        {
            this.UpdateContent();
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.SaveContent();
        }

        private void LoadContent()
        {
            _entries.Clear();
            if (!File.Exists(this.ContentFilePath))
                return;

            using (var sr = new StreamReader(this.ContentFilePath))
            {
                string line;
                while ((line = sr.ReadLine()) != null)
                {
                    var parts = line.Split('\t');
                    if (parts.Length == 2)
                    {
                        var name = parts[0].Trim();
                        var url = parts[1].Trim();
                        if(name.Length > 0 && url.Length > 0)
                            _entries.Add(new Entry { Name = parts[0], Url = parts[1] });
                    }
                }
            }
        }

        private void SaveContent()
        {
            var path = this.ContentFilePath;
            var dir = Path.GetDirectoryName(path);
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);
            using (var sw = new StreamWriter(this.ContentFilePath))
            {
                foreach (var entry in _entries)
                    sw.WriteLine(string.Format("{0}\t{1}", entry.Name, entry.Url));
            }
        }
    }

    public class Entry
    {
        public string Name { get; set; }
        public string Url { get; set; }
    }
}
