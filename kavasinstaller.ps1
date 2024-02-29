Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$translations = @{
    "en-US" = @{
        "Compression" = "Compression";
        "Development" = "Development";
        "Documents" = "Documents";
        "Imaging" = "Imaging";
        "Messaging" = "Messaging";
        "Web Browsers" = "Web Browsers";
        "File Sharing" = "File Sharing";
        "Media" = "Media";
        "Gaming" = "Gaming";
        "Utilities" = "Utilities";
        "Dependencices" = "Dependencies";
        "Title" = "Kavas Installer v0.1";
        "Install" = "Install";
        "Complete" = "Installation Complete";
        "NoSelection" = "No applications selected.";
        "Waiting" = "Waiting for installation to start...";
        "Installing" = "Installing";
        "wingetNotInstalled" = "winget is not installed. Please install it manually through the Microsoft Store by searching for 'App Installer' or check the documentation for your Windows version for alternative installation methods."
    }
    "tr-TR" = @{
        "Compression" = "Sıkıştırma";
        "Development" = "Geliştirme";
        "Documents" = "Dokümanlar";
        "Imaging" = "Görüntüleme";
        "Messaging" = "Mesajlaşma";
        "Web Browsers" = "Web Tarayıcılar";
        "File Sharing" = "Dosya Paylaşımı";
        "Media" = "Medya";
        "Gaming" = "Oyunlar";
        "Utilities" = "Araçlar";
        "Dependencies" = "Bağımlılıklar";
        "Title" = "Kavas Yükleyici v0.1";
        "Install" = "Yükle";
        "Complete" = "Yükleme Tamamlandı";
        "NoSelection" = "Hiçbir uygulama seçilmedi.";
        "Waiting" = "Yüklemenin başlaması bekleniyor...";
        "Installing" = "Yükleniyor";
        "wingetNotInstalled" = "winget yüklü değil. Lütfen 'App Installer' uygulamasını Microsoft Store'dan arayarak manuel olarak yükleyin veya alternatif yükleme yöntemleri için Windows sürümünüzün belgelerine bakın."
    }
}

function Get-LocalizedText {
    param (
        [string]$key
    )
    $currentCulture = (Get-Culture).Name
    if ($translations.ContainsKey($currentCulture) -and $translations[$currentCulture].ContainsKey($key)) {
        return $translations[$currentCulture][$key]
    } elseif ($translations["en-US"].ContainsKey($key)) {
        # Fallback to English if the current culture is not supported or the key is missing
        return $translations["en-US"][$key]
    } else {
        return "Undefined"
    }
}


# Check if winget is available
if (-not(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output $(Get-LocalizedText -key 'wingetNotInstalled')
    exit
}

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = Get-LocalizedText -key 'Title'
$form.AutoSize = $true # Enable auto-sizing of the form
$form.AutoSizeMode = 'GrowAndShrink' # Allow the form to shrink or grow according to its content
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Define the applications with IDs, names, and categories
$applications = @(
    @{ Category = Get-LocalizedText -key 'Compression'; ID = '7zip.7zip'; Name = '7-Zip' },
    @{ Category = Get-LocalizedText -key 'Compression'; ID = 'Giorgiotani.Peazip'; Name = 'PeaZip' },
    @{ Category = Get-LocalizedText -key 'Compression'; ID = 'RARLab.WinRAR'; Name = 'WinRAR' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'Notepad++.Notepad++'; Name = 'Notepad++' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'Microsoft.VisualStudioCode'; Name = 'Visual Studio Code' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'Python.Python.3.12'; Name = 'Python 3.12' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'PuTTY.PuTTY'; Name = 'PuTTY' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'WinSCP.WinSCP'; Name = 'WinSCP' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'WinMerge.WinMerge'; Name = 'WinMerge' },
    @{ Category = Get-LocalizedText -key 'Dependencies'; ID = 'abbodi1406.vcredist'; Name = 'MS Visual C++ AIO' },
    @{ Category = Get-LocalizedText -key 'Dependencies'; ID = 'Microsoft.DirectX'; Name = 'DirectX' },
    @{ Category = Get-LocalizedText -key 'Development'; ID = 'Termius.Termius'; Name = 'Termius' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'Adobe.Acrobat.Reader.64-bit'; Name = 'Adobe Acrobat Reader' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'Foxit.FoxitReader'; Name = 'Foxit PDF Reader' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'TheDocumentFoundation.LibreOffice'; Name = 'LibreOffice' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'Kingsoft.WPSOffice.CN'; Name = 'WPS Office' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'Apache.OpenOffice'; Name = 'OpenOffice' },
    @{ Category = Get-LocalizedText -key 'Imaging'; ID = 'IrfanSkiljan.IrfanView'; Name = 'IrfanView' },
    @{ Category = Get-LocalizedText -key 'Imaging'; ID = 'dotPDNLLC.paintdotnet'; Name = 'Paint.NET' },
    @{ Category = Get-LocalizedText -key 'Imaging'; ID = 'GIMP.GIMP'; Name = 'GIMP' },
    @{ Category = Get-LocalizedText -key 'Imaging'; ID = 'BlenderFoundation.Blender'; Name = 'Blender' },
    @{ Category = Get-LocalizedText -key 'Messaging'; ID = 'Discord.Discord'; Name = 'Discord' },
    @{ Category = Get-LocalizedText -key 'Messaging'; ID = 'Microsoft.Skype'; Name = 'Skype' },
    @{ Category = Get-LocalizedText -key 'Messaging'; ID = 'Mozilla.Thunderbird'; Name = 'Thunderbird' },
    @{ Category = Get-LocalizedText -key 'Messaging'; ID = 'Zoom.Zoom'; Name = 'Zoom' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Ablaze.Floorp'; Name = 'Floorp' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Brave.Brave'; Name = 'Brave' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Google.Chrome'; Name = 'Google Chrome' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Mozilla.Firefox'; Name = 'Firefox' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Vivaldi.Vivaldi'; Name = 'Vivaldi' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Opera.Opera'; Name = 'Opera' },
    @{ Category = Get-LocalizedText -key 'Web Browsers'; ID = 'Opera.OperaGX'; Name = 'Opera GX' },
    @{ Category = Get-LocalizedText -key 'File Sharing'; ID = 'qBittorrent.qBittorrent'; Name = 'qBittorrent' },
    @{ Category = Get-LocalizedText -key 'File Sharing'; ID = 'Tonec.InternetDownloadManager'; Name = 'Internet Download Manager' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'VideoLAN.VLC'; Name = 'VLC Media Player' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'CodecGuide.K-LiteCodecPack.Full'; Name = 'K-Lite Codec Pack' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'GOMLab.GOMPlayer'; Name = 'GOM Player' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'Spotify.Spotify'; Name = 'Spotify' },
    @{ Category = Get-LocalizedText -key 'Gaming'; ID = 'Valve.Steam'; Name = 'Steam' },
    @{ Category = Get-LocalizedText -key 'Gaming'; ID = 'EpicGames.EpicGamesLauncher'; Name = 'Epic Games Launcher' },
    @{ Category = Get-LocalizedText -key 'Gaming'; ID = 'Ubisoft.Connect'; Name = 'Ubisoft Connect' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'TeamViewer.TeamViewer'; Name = 'TeamViewer' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'CodeSector.TeraCopy'; Name = 'TeraCopy' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'WinDirStat.WinDirStat'; Name = 'WinDirStat' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'Open-Shell.Open-Shell-Menu'; Name = 'Open Shell' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'Piriform.CCleaner'; Name = 'CCleaner' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'AntibodySoftware.WizTree'; Name = 'WizTree' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'TeamViewer.TeamViewer'; Name = 'TeamViewer' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'Guru3D.Afterburner'; Name = 'MSI Afterburner' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'FxSoundLLC.FxSound'; Name = 'FxSound' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'HiBitSoftware.StartUpManager'; Name = 'HiBit StartUp Manager' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'HiBitSoftware.HiBitUninstaller'; Name = 'HiBit Uninstaller' },
    @{ Category = Get-LocalizedText -key 'Utilities'; ID = 'RevoUninstaller.RevoUninstaller'; Name = 'Revo Uninstaller' }
)

# Group applications by category
$groupedApplications = @{}
foreach ($obj in $applications) {
    # Check if the hashtable does not contain the category key and add it if necessary
    if (-not $groupedApplications.ContainsKey($obj.Category)) {
        $groupedApplications[$obj.Category] = @()
    }
    
    # Add the object to the appropriate category in the hashtable
    $groupedApplications[$obj.Category] += $obj
}

# Calculate the number of columns needed (max 2 categories per column)
$columnsNeeded = [math]::Floor($groupedApplications.Count / 2.0)
$columnWidth = 200 # Define column width
$formWidth = $columnWidth * $columnsNeeded # Calculate form width based on columns needed
$form.Width = $formWidth
$form.Height = 600

# Layout variables
$xPos = 10
$yPos = 10
$columnHeight = 0

# Create UI elements grouped by category and adjust for columns

$idx = 1

foreach ($group in $groupedApplications.Keys) {
    # Create a label for the category
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $group
    $label.Location = New-Object System.Drawing.Point($xPos, $yPos)
    $label.AutoSize = $true
    $form.Controls.Add($label)
    $yPos += 30

    # Create a checkbox for each application in the category
    foreach ($app in $groupedApplications[$group]) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $app.Name
        $checkbox.Tag = $app.ID # Use the Tag property to store the application ID
        $checkboxLoc = $xPos + 10
        $checkbox.Location = New-Object System.Drawing.Point($checkboxLoc, $yPos) # Indent checkboxes for visual grouping
        $checkbox.AutoSize = $true
        $form.Controls.Add($checkbox)
        $yPos += 20
    }

    $yPos += 10 # Add some space before the next category
    $columnHeight = [math]::Max($columnHeight, $yPos) # Track max column height
    # Increment column index after every second category
    # Reset yPos for each new column, and adjust xPos based on columnIndex
    if (($idx % 2) -eq 0) {
        $xPos += $columnWidth
        $yPos = 10
    }

    $idx++
}

# Adjust yPos for the progress bar and install button based on the tallest column
$yPos = $columnHeight + 10

# Initialize and place the progress bar at the bottom, spanning across all columns
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, $yPos)
$progressBar.Style = 'Continuous'
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$progressBar.Step = 1
$progressBarSize = $formWidth - 105
$progressBar.Size = New-Object System.Drawing.Size($progressBarSize, 10) # Span across the form width
$form.Controls.Add($progressBar)


# Initialize and place the label for current installing program above the progress bar
$installingLabel = New-Object System.Windows.Forms.Label
$installingLabelLocation = $yPos + 25
$installingLabel.Location = New-Object System.Drawing.Point(10, $installingLabelLocation) # Position above the progress bar
$installingLabel.Size = New-Object System.Drawing.Size($progressBarSize, 20) # Same width as the progress bar for alignment
$installingLabel.Text = Get-LocalizedText -key 'Waiting'
$form.Controls.Add($installingLabel)

# Update yPos for the progress bar based on the new label, adding space
$yPos += 20 # Adjust if needed based on actual layout

# Update yPos for the install button, adding space after the progress bar
$yPos += 50

# Initialize and center the install button below the progress bar
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = Get-LocalizedText -key 'Install'
$buttonInstallLocation = ($formWidth - 200) / 2 # Center the button
$buttonInstall.Location = New-Object System.Drawing.Point($buttonInstallLocation, $yPos) # Center the button
$buttonInstall.Size = New-Object System.Drawing.Size(100, 50)
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::GetFolderPath('System') + '\msiexec.exe')
$buttonInstall.Image = $icon.ToBitmap()
$buttonInstall.TextAlign = 'MiddleRight'
$buttonInstall.TextImageRelation = 'ImageBeforeText'
$form.Controls.Add($buttonInstall)


# Add an event handler for the install button click
$buttonInstall.Add_Click({
    # Initialize an array to hold selected applications
    $selectedApps = @()

    # Iterate through the form's controls to find checked checkboxes
    $form.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckBox] -and $_.Checked } | ForEach-Object {
        # Add each selected application to the array
        $selectedApp = @{ID = $_.Tag; Name = $_.Text}
        $selectedApps += $selectedApp
    }

    # Check if any applications were selected
    if ($selectedApps.Count -gt 0) {
        $progressBar.Value = 0
        $progressBar.Maximum = $selectedApps.Count
        foreach ($app in $selectedApps) {
            # Update label with the current installing application's name
            $installingLabel.Text = "[$($ProgressBar.Value + 1)/$($selectedApps.Count)] $(Get-LocalizedText -key 'Installing'): $($app.Name)"
            winget.exe install $app.ID -e
            $progressBar.PerformStep()
        }
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "Complete"))
        $installingLabel.Text = Get-LocalizedText -key "Complete"
    } else {
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "NoSelection"))
    }
})

# Add the install button to the form
$form.Controls.Add($buttonInstall)

# About button
#$aboutButton = New-Object System.Windows.Forms.Button
#$aboutButton.Text = 'About'
#$aboutButton.Location = New-Object System.Drawing.Point(($formWidth - 300), $yPos)
#
#$icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::GetFolderPath('System') + '\msinfo32.exe')
#$aboutButton.Image = $icon.ToBitmap()
#$aboutButton.TextAlign = 'MiddleRight'
#$aboutButton.TextImageRelation = 'ImageBeforeText'
#
#
#$aboutButton.Size = New-Object System.Drawing.Size(100, 50)
#$aboutButton.Add_Click({
#    # About dialog form
#    $aboutForm = New-Object System.Windows.Forms.Form
#    $aboutForm.StartPosition = 'CenterScreen'
#    $aboutForm.Size = New-Object System.Drawing.Size(300, 200)
#    $aboutForm.Text = 'About Developer'
#
#    # Developer info
#    $infoLabel = New-Object System.Windows.Forms.Label
#    $infoLabel.Text = "Developer: Emircan Kavas`nEmail: emircankavas@yandex.com`nWebsite: https://kavas.dev"
#    $infoLabel.Location = New-Object System.Drawing.Point(10, 10)
#    $infoLabel.Size = New-Object System.Drawing.Size(280, 120)
#    $infoLabel.AutoSize = $true
#
#    $aboutForm.Controls.Add($infoLabel)
#    $aboutForm.ShowDialog()
#})
#$form.Controls.Add($aboutButton)

# Show the form
$form.ShowDialog()
