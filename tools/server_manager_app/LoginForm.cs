namespace ProjectP1ServerManager;

internal sealed class LoginForm : Form
{
    private readonly TextBox _serverUrl = new() { Width = 360 };
    private readonly TextBox _token = new() { Width = 360, UseSystemPasswordChar = true };
    private readonly CheckBox _rememberToken = new() { Text = "Remember token" };
    private readonly Button _login = new() { Text = "Login", Width = 120 };
    private readonly Label _status = new() { AutoSize = true };

    public AppState State { get; }
    public AdminSession? Session { get; private set; }

    public LoginForm(AppState state)
    {
        State = state;
        Text = "Project P1L0T Server Manager Login";
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        StartPosition = FormStartPosition.CenterScreen;
        Width = 480;
        Height = 260;

        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 5,
            Padding = new Padding(12)
        };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 92));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        root.Controls.Add(new Label { Text = "Server URL", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0);
        root.Controls.Add(_serverUrl, 1, 0);

        root.Controls.Add(new Label { Text = "Admin Token", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 1);
        root.Controls.Add(_token, 1, 1);
        root.Controls.Add(_rememberToken, 1, 2);

        var buttonFlow = new FlowLayoutPanel { Dock = DockStyle.Fill, FlowDirection = FlowDirection.LeftToRight };
        buttonFlow.Controls.Add(_login);
        buttonFlow.Controls.Add(new Button { Text = "Cancel", Width = 120, DialogResult = DialogResult.Cancel });
        root.Controls.Add(buttonFlow, 1, 3);
        root.Controls.Add(_status, 1, 4);
        Controls.Add(root);

        AcceptButton = _login;
        CancelButton = buttonFlow.Controls.OfType<Button>().Last();

        _serverUrl.Text = string.IsNullOrWhiteSpace(state.ServerUrl) ? "http://127.0.0.1:4280" : state.ServerUrl;
        _token.Text = state.LastToken ?? "";
        _rememberToken.Checked = !string.IsNullOrWhiteSpace(_token.Text);

        _login.Click += async (_, _) => await LoginAsync();
    }

    private async Task LoginAsync()
    {
        var url = _serverUrl.Text.Trim().TrimEnd('/');
        var token = _token.Text.Trim();
        if (string.IsNullOrWhiteSpace(url) || string.IsNullOrWhiteSpace(token))
        {
            _status.Text = "Server URL and token are required.";
            return;
        }

        _login.Enabled = false;
        _status.Text = "Validating...";
        try
        {
            using var client = new ServerApiClient(new AdminSession { ServerUrl = url, Token = token });
            var ok = await client.ValidateLoginAsync();
            if (!ok)
            {
                _status.Text = "Login failed. Check token or server.";
                return;
            }

            Session = new AdminSession
            {
                ServerUrl = url,
                Token = token
            };

            State.ServerUrl = url;
            State.LastToken = _rememberToken.Checked ? token : "";
            DialogResult = DialogResult.OK;
            Close();
        }
        catch (Exception ex)
        {
            _status.Text = $"Login failed: {ex.Message}";
        }
        finally
        {
            _login.Enabled = true;
        }
    }
}
