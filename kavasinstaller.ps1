# Kavas Installer 2.0 - entry point.
# NOTE: this file is intentionally pure ASCII. All localized/non-ASCII text lives in
# strings.json and is read back explicitly as UTF-8. That keeps the script immune to the
# PowerShell 5.1 "no BOM = ANSI" problem, so it parses identically whether it is run with
# `irm <url> | iex` or with `powershell -File launcher.ps1`.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:BaseUrl    = 'https://raw.githubusercontent.com/emircankavas/kavasinstaller/main'
$script:AppVersion = '2.0'

# ---------------------------------------------------------------- resources

$launchDir = $null
if ($MyInvocation.MyCommand.Path) { $launchDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

function Read-Utf8Text {
    param([string]$Source)
    if ($Source -match '^https?://') {
        $ProgressPreference = 'SilentlyContinue'
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = New-Object System.Text.UTF8Encoding($false)
        return $wc.DownloadString($Source)
    }
    $p = $Source -replace '^file:///', ''
    return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
}

function Resolve-Resource {
    param([string]$Name)
    $candidates = @()
    if ($launchDir) { $candidates += (Join-Path $launchDir $Name) }
    $candidates += $Name
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return (Resolve-Path -LiteralPath $c).Path }
    }
    return "$script:BaseUrl/$Name"
}

$catalog = (Read-Utf8Text (Resolve-Resource 'catalog.json')) | ConvertFrom-Json
$strings = (Read-Utf8Text (Resolve-Resource 'strings.json')) | ConvertFrom-Json

$script:Lang = 'en-US'
$requested = (Get-Culture).Name
if ($strings.PSObject.Properties.Name -contains $requested) { $script:Lang = $requested }

function T {
    param([string]$Key)
    $d = $strings.$($script:Lang)
    if ($d.PSObject.Properties.Name -contains $Key) { return $d.$Key }
    return $strings.'en-US'.$Key
}
function TCat {
    param([string]$Name)
    $d = $strings.$($script:Lang)
    $v = $d.Categories.$Name
    if ($v) { return $v }
    return $strings.'en-US'.Categories.$Name
}

# ---------------------------------------------------------------- model

Add-Type -ReferencedAssemblies 'WindowsBase','PresentationFramework' -TypeDefinition @'
using System.ComponentModel;
public class AppCard : INotifyPropertyChanged {
    public string ID { get; set; }
    public string Name { get; set; }
    public string Category { get; set; }
    public bool Match { get; set; }
    private bool _checked;
    public bool Checked { get { return _checked; } set { _checked = value; Raise("Checked"); } }
    private string _status;
    public string Status { get { return _status; } set { _status = value; Raise("Status"); } }
    private string _statusKind = "";
    public string StatusKind { get { return _statusKind; } set { _statusKind = value; Raise("StatusKind"); } }
    public string StatusKey { get; set; }
    public event PropertyChangedEventHandler PropertyChanged;
    void Raise(string p) { if (PropertyChanged != null) PropertyChanged(this, new PropertyChangedEventArgs(p)); }
}
'@

$allCards = New-Object System.Collections.ArrayList
foreach ($g in $catalog) {
    foreach ($app in $g.Value) {
        $c = New-Object AppCard
        $c.ID = $app.ID
        $c.Name = $app.Name
        $c.Category = $g.Name
        $c.Match = $true
        $c.StatusKey = 'Unknown'
        $c.Status = ''
        $c.StatusKind = ''
        [void]$allCards.Add($c)
    }
}

# ---------------------------------------------------------------- view

$xaml = Read-Utf8Text (Resolve-Resource 'App.xaml')
$reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$script:win = [Windows.Markup.XamlReader]::Load($reader)
$win = $script:win

function N { param([string]$Name) return $win.FindName($Name) }

$TitleBar        = N 'TitleBar'
$AppTitle        = N 'AppTitle'
$Subtitle        = N 'Subtitle'
$BtnMin          = N 'BtnMin'
$BtnMax          = N 'BtnMax'
$BtnClose        = N 'BtnClose'
$CatList         = N 'CatList'
$SearchBox       = N 'SearchBox'
$SearchPlaceholder = N 'SearchPlaceholder'
$SelectedCount   = N 'SelectedCount'
$BtnClear        = N 'BtnClear'
$BtnAll          = N 'BtnAll'
$Cards           = N 'Cards'
$Bar             = N 'Bar'
$StatusText      = N 'StatusText'
$BtnInstall      = N 'BtnInstall'
$BtnUpgrade      = N 'BtnUpgrade'
$BtnUninstall    = N 'BtnUninstall'
$BtnTr           = N 'BtnTr'
$BtnEn           = N 'BtnEn'
$VersionText     = N 'VersionText'

# ---------------------------------------------------------------- filtering

function Apply-Filter {
    $key = $null
    if ($CatList.SelectedItem) { $key = $CatList.SelectedItem.Key }
    $q = ''
    if ($SearchBox.Text) { $q = $SearchBox.Text.ToLower().Trim() }
    $list = New-Object System.Collections.ArrayList
    foreach ($c in $allCards) {
        $okCat = ($null -eq $key) -or ($key -eq '__all__') -or ($c.Category -eq $key)
        $okTxt = ($q -eq '') -or ($c.Name.ToLower().Contains($q))
        $c.Match = ($okCat -and $okTxt)
        if ($c.Match) { [void]$list.Add($c) }
    }
    $Cards.ItemsSource = $list
    if ($q -eq '' -and -not $SearchBox.IsKeyboardFocusWithin) { $SearchPlaceholder.Visibility = 'Visible' }
    else { $SearchPlaceholder.Visibility = 'Collapsed' }
    Update-Count
}

function Update-Count {
    $n = 0
    foreach ($c in $allCards) { if ($c.Checked) { $n++ } }
    $fmt = T 'SelectedCount'
    if ($fmt) { $SelectedCount.Text = ($fmt -f $n) } else { $SelectedCount.Text = "$n" }
}

# ---------------------------------------------------------------- toasts

$script:notify = New-Object System.Windows.Forms.NotifyIcon
$script:notify.Visible = $true
$script:notify.Icon = [System.Drawing.SystemIcons]::Information

function Show-Toast {
    param([string]$Message, [bool]$Warning = $false)
    try {
        $script:notify.Icon = if ($Warning) { [System.Drawing.SystemIcons]::Warning } else { [System.Drawing.SystemIcons]::Information }
        $script:notify.BalloonTipTitle = T 'Title'
        $script:notify.BalloonTipText = $Message
        $script:notify.ShowBalloonTip(5000)
    } catch { }
}

# ---------------------------------------------------------------- winget ops

$script:WingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
if (-not $script:WingetPath) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show((T 'wingetNotInstalled'), (T 'Title')) | Out-Null
    exit
}

function Set-Busy {
    param([bool]$Busy)
    $BtnInstall.IsEnabled   = -not $Busy
    $BtnUpgrade.IsEnabled   = -not $Busy
    $BtnUninstall.IsEnabled = -not $Busy
    $BtnClear.IsEnabled     = -not $Busy
    $BtnAll.IsEnabled       = -not $Busy
}

$script:opQueue = @()
$script:opIndex = 0
$script:opProc = $null
$script:opKind = 'install'
$script:opFailures = @()

function Start-NextOp {
    if ($script:opIndex -ge $script:opQueue.Count) { Finish-Op; return }
    $it = $script:opQueue[$script:opIndex]
    if ($script:opKind -eq 'upgrade') {
        $arguments = 'upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --silent --disable-interactivity'
        $label = T 'Upgrading'
    } else {
        $verb = if ($script:opKind -eq 'uninstall') { 'uninstall' } else { 'install' }
        $arguments = "$verb `"$($it.Id)`" --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
        $verbTxt = if ($script:opKind -eq 'uninstall') { T 'Uninstalling' } else { T 'Installing' }
        $label = "${verbTxt}: $($it.Name)"
    }
    $StatusText.Text = "[$($script:opIndex + 1)/$($script:opQueue.Count)] $label"

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo.FileName = $script:WingetPath
    $p.StartInfo.Arguments = $arguments
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.CreateNoWindow = $true
    [void]$p.Start()
    $script:opProc = $p
}

function Finish-Op {
    $script:opTimer.Stop()
    $Bar.IsIndeterminate = $false
    Set-Busy $false
    $doneKey = 'Complete'
    if ($script:opKind -eq 'uninstall') { $doneKey = 'UninstallComplete' }
    elseif ($script:opKind -eq 'upgrade') { $doneKey = 'UpgradeComplete' }
    if ($script:opFailures.Count -gt 0) {
        $msg = (T 'FailedTitle') + ': ' + ($script:opFailures -join ', ')
        $StatusText.Text = $msg
        Show-Toast $msg $true
    } else {
        $msg = T $doneKey
        $StatusText.Text = $msg
        Show-Toast $msg $false
    }
    Start-Discovery
}

function Start-Op {
    param([string]$Kind, $Items)
    $script:opKind = $Kind
    $script:opQueue = @($Items) + @()
    $script:opIndex = 0
    $script:opFailures = @()
    Set-Busy $true
    $Bar.Value = 0
    $Bar.Maximum = [Math]::Max(1, $script:opQueue.Count)
    $Bar.IsIndeterminate = ($Kind -eq 'upgrade')
    $script:opTimer.Start()
    Start-NextOp
}

function Get-Checked {
    $res = @()
    foreach ($c in $allCards) { if ($c.Checked) { $res += @{ Id = $c.ID; Name = $c.Name } } }
    return $res
}

# ---------------------------------------------------------------- discovery

function Start-Discovery {
    # Do not overwrite live operation feedback; discovery will retry when the op ends
    if ($null -ne $script:opProc) { return }
    $StatusText.Text = T 'Working'
    try {
        $script:discJob = Start-Job -ScriptBlock { param($w) & $w list --accept-source-agreements 2>$null } -ArgumentList $script:WingetPath
        $script:discTimer.Start()
    } catch {
        Invoke-Discovery -Output (& $script:WingetPath list --accept-source-agreements 2>$null | Out-String)
    }
}

function Invoke-Discovery {
    param([string]$Output)
    $installed = @{}
    foreach ($line in ($Output -split "`r?`n")) {
        $parts = [regex]::Split($line.Trim(), '\s{2,}')
        if ($parts.Count -ge 3) {
            $id = $parts[1]
            if ($id -match '\.' -or $id -match '^[0-9A-Z]{12}$') {
                $avail = $null
                if ($parts.Count -ge 4) { $avail = $parts[3] }
                $installed[$id] = @{ Version = $parts[2]; Available = $avail }
            }
        }
    }
    foreach ($c in $allCards) {
        if ($installed.ContainsKey($c.ID)) {
            $avail = $installed[$c.ID].Available
            if ($avail -and $avail -match '^[0-9]') {
                $c.StatusKey = 'UpdateAvailable'; $c.StatusKind = 'update'
            } else {
                $c.StatusKey = 'Installed'; $c.StatusKind = 'installed'
            }
        } else {
            $c.StatusKey = 'NotInstalled'; $c.StatusKind = ''
        }
        $c.Status = T $c.StatusKey
    }
    $StatusText.Text = ''
}

# ---------------------------------------------------------------- language

function Set-Lang {
    param([string]$Lang)
    if ($strings.PSObject.Properties.Name -contains $Lang) { $script:Lang = $Lang }

    $win.Title = T 'Title'
    $AppTitle.Text = T 'Title'
    $Subtitle.Text = T 'Subtitle'
    $SearchPlaceholder.Text = T 'SearchPlaceholder'
    $BtnInstall.Content = T 'Install'
    $BtnUpgrade.Content = T 'Upgrade'
    $BtnUninstall.Content = T 'Uninstall'
    $BtnClear.Content = T 'ClearSelection'
    $BtnAll.Content = T 'SelectAll'
    $VersionText.Text = "v$script:AppVersion" + "  .  " + $script:Lang

    $oldKey = $null
    if ($CatList.SelectedItem) { $oldKey = $CatList.SelectedItem.Key }

    $items = New-Object System.Collections.ArrayList
    $total = 0
    foreach ($c in $allCards) { $total++ }
    [void]$items.Add([pscustomobject]@{ Key = '__all__'; Text = (T 'All') + "   $total" })
    foreach ($g in $catalog) {
        $n = $g.Value.Count
        [void]$items.Add([pscustomobject]@{ Key = $g.Name; Text = (TCat $g.Name) + "   $n" })
    }
    $CatList.ItemsSource = $items
    $CatList.DisplayMemberPath = 'Text'
    $idx = 0
    for ($i = 0; $i -lt $items.Count; $i++) { if ($items[$i].Key -eq $oldKey) { $idx = $i; break } }
    $CatList.SelectedIndex = $idx

    foreach ($c in $allCards) { $c.Status = T $c.StatusKey }
    Apply-Filter
}

# ---------------------------------------------------------------- events

$TitleBar.Add_MouseLeftButtonDown({ $win.DragMove() })
$BtnMin.Add_Click({ $win.WindowState = 'Minimized' })
$BtnMax.Add_Click({
    if ($win.WindowState -eq 'Maximized') { $win.WindowState = 'Normal' } else { $win.WindowState = 'Maximized' }
})
$BtnClose.Add_Click({ $win.Close() })

$CatList.Add_SelectionChanged({ Apply-Filter })
$SearchBox.Add_TextChanged({ Apply-Filter })
$SearchBox.Add_GotKeyboardFocus({ $SearchPlaceholder.Visibility = 'Collapsed' })
$SearchBox.Add_LostKeyboardFocus({ if (-not $SearchBox.Text) { $SearchPlaceholder.Visibility = 'Visible' } })

$BtnClear.Add_Click({
    foreach ($c in $allCards) { if ($c.Match) { $c.Checked = $false } }
    Update-Count
})
$BtnAll.Add_Click({
    foreach ($c in $allCards) { if ($c.Match) { $c.Checked = $true } }
    Update-Count
})

$BtnInstall.Add_Click({
    $items = Get-Checked
    if ($items.Count -eq 0) { Show-Toast (T 'NothingSelected') $true; return }
    Start-Op 'install' $items
})

$BtnUninstall.Add_Click({
    $items = Get-Checked
    if ($items.Count -eq 0) { Show-Toast (T 'NothingSelected') $true; return }
    Add-Type -AssemblyName System.Windows.Forms
    $names = ($items | ForEach-Object { $_.Name }) -join ', '
    $answer = [System.Windows.Forms.MessageBox]::Show(((T 'ConfirmUninstall') + "`n`n" + $names), (T 'Title'), 'YesNo', 'Warning')
    if ($answer -ne 'Yes') { return }
    Start-Op 'uninstall' $items
})

$BtnUpgrade.Add_Click({
    $StatusText.Text = T 'Working'
    $pending = & $script:WingetPath upgrade --accept-source-agreements 2>$null | Out-String
    if ($pending -match 'No installed package|No applicable upgrade|0 package\(s\)') {
        $StatusText.Text = T 'NothingToUpgrade'
        Show-Toast (T 'NothingToUpgrade') $false
        return
    }
    Start-Op 'upgrade' @(@{ Id = '__all__'; Name = 'all' })
})

$BtnTr.Add_Click({ Set-Lang 'tr-TR' })
$BtnEn.Add_Click({ Set-Lang 'en-US' })

# timers
$script:opTimer = New-Object System.Windows.Forms.Timer
$script:opTimer.Interval = 300
$script:opTimer.Add_Tick({
    if ($null -ne $script:opProc -and $script:opProc.HasExited) {
        $code = $script:opProc.ExitCode
        if ($code -ne 0) { $script:opFailures += $script:opQueue[$script:opIndex].Name }
        $script:opProc = $null
        if ($script:opKind -ne 'upgrade') { $Bar.Value = $script:opIndex + 1 }
        $script:opIndex++
        Start-NextOp
    }
})

$script:discTimer = New-Object System.Windows.Forms.Timer
$script:discTimer.Interval = 500
$script:discTimer.Add_Tick({
    if ($null -ne $script:discJob -and $script:discJob.State -eq 'Completed') {
        $script:discTimer.Stop()
        $out = Receive-Job $script:discJob | Out-String
        Remove-Job $script:discJob -Force
        Invoke-Discovery -Output $out
    }
})

$script:countTimer = New-Object System.Windows.Forms.Timer
$script:countTimer.Interval = 400
$script:countTimer.Add_Tick({ Update-Count })
$script:countTimer.Start()

# ---------------------------------------------------------------- go

Set-Lang $script:Lang
Start-Discovery
[void]$win.ShowDialog()
try { $script:notify.Dispose() } catch { }
