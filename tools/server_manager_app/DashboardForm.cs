using System.Diagnostics;

namespace ProjectP1ServerManager;

internal sealed class DashboardForm : Form
{
    private readonly AdminSession _session;
    private readonly ServerApiClient _api;
    private readonly NotifyIcon _tray;
    private bool _exitRequested;

    private readonly Label _healthSummary = new() { AutoSize = true };
    private readonly TextBox _serverName = new() { Width = 260 };
    private readonly TextBox _websiteTitle = new() { Width = 260 };
    private readonly TextBox _motd = new() { Width = 420, Multiline = true, Height = 60 };
    private readonly NumericUpDown _maxPlayers = new() { Minimum = 1, Maximum = 512, Value = 64 };
    private readonly NumericUpDown _tickRate = new() { Minimum = 10, Maximum = 240, Value = 60 };
    private readonly NumericUpDown _autosave = new() { Minimum = 5, Maximum = 600, Value = 30 };
    private readonly ComboBox _hardware = new() { DropDownStyle = ComboBoxStyle.DropDownList, Width = 180 };
    private readonly CheckBox _allowSignup = new() { Text = "Allow Signup" };
    private readonly CheckBox _maintenance = new() { Text = "Maintenance Mode" };
    private readonly CheckBox _telemetry = new() { Text = "Telemetry Enabled" };
    private readonly DataGridView _users = new() { Dock = DockStyle.Fill, ReadOnly = true, AutoGenerateColumns = false };
    private readonly TextBox _status = new() { Width = 280 };
    private readonly TextBox _bio = new() { Width = 280, Multiline = true, Height = 80 };
    private readonly TextBox _discord = new() { Width = 280 };
    private readonly CheckBox _isAdmin = new() { Text = "Admin" };
    private readonly CheckBox _isEnabled = new() { Text = "Enabled" };
    private readonly TextBox _logs = new() { Multiline = true, ReadOnly = true, Dock = DockStyle.Fill, ScrollBars = ScrollBars.Vertical };

    private List<ServerUser> _cachedUsers = [];
    private string _selectedUserId = "";

    public DashboardForm(AdminSession session)
    {
        _session = session;
        _api = new ServerApiClient(session);
        _tray = new NotifyIcon
        {
            Text = "Project P1L0T Server Manager",
            Icon = SystemIcons.Application,
            Visible = true
        };

        Text = "Project P1L0T Server Manager";
        Width = 1200;
        Height = 760;
        StartPosition = FormStartPosition.CenterScreen;

        _hardware.Items.Add("recommended");
        _hardware.Items.Add("max");

        BuildTrayMenu();
        BuildUi();
        WireEvents();
    }

    protected override async void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        await RefreshAllAsync();
    }

    private void BuildTrayMenu()
    {
        var menu = new ContextMenuStrip();
        menu.Items.Add("Open Dashboard", null, (_, _) => ShowFromTray());
        menu.Items.Add("Open Web Admin", null, (_, _) => OpenWebAdmin());
        menu.Items.Add("Exit", null, (_, _) =>
        {
            _exitRequested = true;
            _tray.Visible = false;
            Close();
        });
        _tray.ContextMenuStrip = menu;
        _tray.DoubleClick += (_, _) => ShowFromTray();
    }

    private void BuildUi()
    {
        var topBar = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            Height = 44,
            Padding = new Padding(8)
        };
        topBar.Controls.Add(new Label { Text = $"Server: {_session.ServerUrl}", AutoSize = true, Padding = new Padding(0, 8, 10, 0) });
        topBar.Controls.Add(new Button { Text = "Refresh", Width = 100, Name = "btnRefresh" });
        topBar.Controls.Add(new Button { Text = "Open Web Admin", Width = 130, Name = "btnWeb" });
        topBar.Controls.Add(new Button { Text = "Start Service", Width = 120, Name = "btnStartService" });
        topBar.Controls.Add(new Button { Text = "Stop Service", Width = 120, Name = "btnStopService" });
        topBar.Controls.Add(_healthSummary);

        var tabs = new TabControl { Dock = DockStyle.Fill };
        tabs.TabPages.Add(BuildSettingsTab());
        tabs.TabPages.Add(BuildUsersTab());
        tabs.TabPages.Add(BuildLogsTab());

        Controls.Add(tabs);
        Controls.Add(topBar);
    }

    private TabPage BuildSettingsTab()
    {
        var page = new TabPage("Settings");
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 4,
            RowCount = 6,
            Padding = new Padding(12)
        };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 320));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        layout.Controls.Add(new Label { Text = "Server Name", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0);
        layout.Controls.Add(_serverName, 1, 0);
        layout.Controls.Add(new Label { Text = "Website Title", AutoSize = true, Anchor = AnchorStyles.Left }, 2, 0);
        layout.Controls.Add(_websiteTitle, 3, 0);

        layout.Controls.Add(new Label { Text = "Hardware", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 1);
        layout.Controls.Add(_hardware, 1, 1);
        layout.Controls.Add(new Label { Text = "Max Players", AutoSize = true, Anchor = AnchorStyles.Left }, 2, 1);
        layout.Controls.Add(_maxPlayers, 3, 1);

        layout.Controls.Add(new Label { Text = "Tick Rate", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 2);
        layout.Controls.Add(_tickRate, 1, 2);
        layout.Controls.Add(new Label { Text = "Autosave (s)", AutoSize = true, Anchor = AnchorStyles.Left }, 2, 2);
        layout.Controls.Add(_autosave, 3, 2);

        layout.Controls.Add(_allowSignup, 0, 3);
        layout.Controls.Add(_maintenance, 1, 3);
        layout.Controls.Add(_telemetry, 2, 3);

        layout.Controls.Add(new Label { Text = "MOTD", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 4);
        layout.SetColumnSpan(_motd, 3);
        layout.Controls.Add(_motd, 1, 4);

        var save = new Button { Text = "Save Settings", Width = 140, Name = "btnSaveSettings" };
        layout.Controls.Add(save, 1, 5);

        page.Controls.Add(layout);
        return page;
    }

    private TabPage BuildUsersTab()
    {
        var page = new TabPage("Users");
        var split = new SplitContainer
        {
            Dock = DockStyle.Fill,
            SplitterDistance = 760
        };

        _users.Columns.Add(new DataGridViewTextBoxColumn { DataPropertyName = "Id", HeaderText = "ID", Width = 160 });
        _users.Columns.Add(new DataGridViewTextBoxColumn { DataPropertyName = "Username", HeaderText = "Username", Width = 140 });
        _users.Columns.Add(new DataGridViewTextBoxColumn { DataPropertyName = "Email", HeaderText = "Email", Width = 220 });
        _users.Columns.Add(new DataGridViewCheckBoxColumn { DataPropertyName = "IsAdmin", HeaderText = "Admin", Width = 70 });
        _users.Columns.Add(new DataGridViewCheckBoxColumn { DataPropertyName = "Enabled", HeaderText = "Enabled", Width = 70 });
        split.Panel1.Controls.Add(_users);

        var detail = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 8,
            Padding = new Padding(10)
        };
        detail.Controls.Add(new Label { Text = "Status", AutoSize = true }, 0, 0);
        detail.Controls.Add(_status, 0, 1);
        detail.Controls.Add(new Label { Text = "Discord", AutoSize = true }, 0, 2);
        detail.Controls.Add(_discord, 0, 3);
        detail.Controls.Add(new Label { Text = "Bio", AutoSize = true }, 0, 4);
        detail.Controls.Add(_bio, 0, 5);
        detail.Controls.Add(_isAdmin, 0, 6);
        detail.Controls.Add(_isEnabled, 0, 7);
        var saveUser = new Button { Text = "Save User", Width = 120, Name = "btnSaveUser" };
        detail.Controls.Add(saveUser, 0, 8);

        split.Panel2.Controls.Add(detail);
        page.Controls.Add(split);
        return page;
    }

    private TabPage BuildLogsTab()
    {
        var page = new TabPage("Logs");
        var refreshLogs = new Button { Text = "Refresh Logs", Dock = DockStyle.Top, Height = 36, Name = "btnRefreshLogs" };
        page.Controls.Add(_logs);
        page.Controls.Add(refreshLogs);
        return page;
    }

    private void WireEvents()
    {
        FormClosing += (_, e) =>
        {
            if (_exitRequested)
            {
                _tray.Visible = false;
                _api.Dispose();
                return;
            }

            e.Cancel = true;
            Hide();
            ShowInTaskbar = false;
            _tray.BalloonTipTitle = "Project P1L0T Server Manager";
            _tray.BalloonTipText = "Running in system tray.";
            _tray.ShowBalloonTip(1200);
        };

        Resize += (_, _) =>
        {
            if (WindowState == FormWindowState.Minimized)
            {
                Hide();
                ShowInTaskbar = false;
            }
        };

        _users.SelectionChanged += (_, _) => LoadSelectedUserIntoForm();

        Controls.Find("btnRefresh", true).First().Click += async (_, _) => await RefreshAllAsync();
        Controls.Find("btnWeb", true).First().Click += (_, _) => OpenWebAdmin();
        Controls.Find("btnStartService", true).First().Click += (_, _) => ControlService("start");
        Controls.Find("btnStopService", true).First().Click += (_, _) => ControlService("stop");
        Controls.Find("btnSaveSettings", true).First().Click += async (_, _) => await SaveSettingsAsync();
        Controls.Find("btnSaveUser", true).First().Click += async (_, _) => await SaveUserAsync();
        Controls.Find("btnRefreshLogs", true).First().Click += async (_, _) => await LoadLogsAsync();
    }

    private async Task RefreshAllAsync()
    {
        try
        {
            var health = await _api.GetHealthAsync();
            _healthSummary.Text = $"  {health.ServerName} | profile={health.HardwareProfile} | players={health.MaxPlayers} | tick={health.TickRate}";

            var settings = await _api.GetSettingsAsync();
            _serverName.Text = settings.ServerName;
            _websiteTitle.Text = settings.WebsiteTitle;
            _motd.Text = settings.Motd;
            _allowSignup.Checked = settings.AllowSignup;
            _maintenance.Checked = settings.MaintenanceMode;
            _telemetry.Checked = settings.TelemetryEnabled;
            _hardware.SelectedItem = settings.HardwareProfile;
            _maxPlayers.Value = settings.MaxPlayers;
            _tickRate.Value = settings.TickRate;
            _autosave.Value = settings.AutosaveSeconds;

            _cachedUsers = await _api.GetUsersAsync();
            _users.DataSource = null;
            _users.DataSource = _cachedUsers;

            await LoadLogsAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Refresh failed: {ex.Message}", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private async Task SaveSettingsAsync()
    {
        try
        {
            var settings = new ServerSettings
            {
                ServerName = _serverName.Text,
                WebsiteTitle = _websiteTitle.Text,
                Motd = _motd.Text,
                AllowSignup = _allowSignup.Checked,
                MaintenanceMode = _maintenance.Checked,
                TelemetryEnabled = _telemetry.Checked,
                HardwareProfile = _hardware.SelectedItem?.ToString() ?? "recommended",
                MaxPlayers = (int)_maxPlayers.Value,
                TickRate = (int)_tickRate.Value,
                AutosaveSeconds = (int)_autosave.Value,
                MaxUploadMb = 64
            };
            await _api.SaveSettingsAsync(settings);
            MessageBox.Show("Settings saved.", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Information);
            await RefreshAllAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Save settings failed: {ex.Message}", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void LoadSelectedUserIntoForm()
    {
        if (_users.CurrentRow?.DataBoundItem is not ServerUser user)
        {
            _selectedUserId = "";
            return;
        }
        _selectedUserId = user.Id;
        _status.Text = user.Status ?? "";
        _bio.Text = user.Bio ?? "";
        _discord.Text = user.Discord ?? "";
        _isAdmin.Checked = user.IsAdmin;
        _isEnabled.Checked = user.Enabled;
    }

    private async Task SaveUserAsync()
    {
        if (string.IsNullOrWhiteSpace(_selectedUserId))
        {
            MessageBox.Show("Select a user first.", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        try
        {
            var user = await _api.GetUserAsync(_selectedUserId);
            user.Status = _status.Text;
            user.Bio = _bio.Text;
            user.Discord = _discord.Text;
            user.IsAdmin = _isAdmin.Checked;
            user.Enabled = _isEnabled.Checked;
            await _api.SaveUserAsync(user);
            MessageBox.Show("User updated.", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Information);
            await RefreshAllAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Save user failed: {ex.Message}", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private async Task LoadLogsAsync()
    {
        try
        {
            var lines = await _api.GetLogsAsync();
            _logs.Text = string.Join(Environment.NewLine, lines);
        }
        catch (Exception ex)
        {
            _logs.Text = $"Failed to load logs: {ex.Message}";
        }
    }

    private void OpenWebAdmin()
    {
        var url = _session.ServerUrl.TrimEnd('/') + "/admin/";
        Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
    }

    private void ControlService(string action)
    {
        try
        {
            var psi = new ProcessStartInfo("sc.exe", $"{action} ProjectP1L0TServer")
            {
                UseShellExecute = false,
                CreateNoWindow = true
            };
            var proc = Process.Start(psi);
            proc?.WaitForExit(5000);
            _ = RefreshAllAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Service action failed: {ex.Message}", "Server Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void ShowFromTray()
    {
        Show();
        WindowState = FormWindowState.Normal;
        ShowInTaskbar = true;
        Activate();
    }
}
