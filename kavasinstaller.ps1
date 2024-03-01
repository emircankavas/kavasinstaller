Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$appVersion = "0.1"

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
        "Title" = "Kavas Installer $appVersion";
        "Install" = "Install";
        "Complete" = "Installation Complete";
        "NoSelection" = "No applications selected.";
        "Waiting" = "Waiting for installation to start...";
        "Installing" = "Installing";
        "Search" = "Start typing to search";
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
        "Title" = "Kavas Yükleyici $appVersion";
        "Install" = "Yükle";
        "Complete" = "Yükleme Tamamlandı";
        "NoSelection" = "Hiçbir uygulama seçilmedi.";
        "Waiting" = "Yüklemenin başlaması bekleniyor...";
        "Installing" = "Yükleniyor";
        "Search" = "Aramak için yazmaya başlayın";
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

function Get-Image {
    param (
        [string]$url
    )
    $tempFilePath = [System.IO.Path]::GetTempFileName()
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $tempFilePath

    return $tempFilePath
}


# Check if winget is available
if (-not(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output $(Get-LocalizedText -key 'wingetNotInstalled')
    exit
}



# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = Get-LocalizedText -key 'Title'
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = 'FixedDialog'

$url = "https://preview.redd.it/w0qg2oanfel51.png?width=1080&crop=smart&auto=webp&s=46e6727910dc87c062f10ea077f2485d70eb428f"
$backgroundImage = $(Get-Image -url $url)

$form.BackgroundImage = [System.Drawing.Image]::FromFile($backgroundImage)
$form.BackgroundImageLayout = "Stretch"

$apps = @"
[   
    {
        "Name": "Compression",
        "Value": [
            { "ID": "7zip.7zip", "Name": "7-Zip" },
            { "ID": "Giorgiotani.Peazip", "Name": "PeaZip" },
            { "ID": "RARLab.WinRAR", "Name": "WinRAR" }
        ],
        "Icon": "https://w7.pngwing.com/pngs/692/333/png-transparent-data-compression-computer-icons-data-compression-logo-artwork-symbol.png"
    },
    {
        "Name": "Development",
        "Value": [
            { "ID": "Notepad++.Notepad++", "Name": "Notepad++" },
            { "ID": "Microsoft.VisualStudioCode", "Name": "Visual Studio Code" },
            { "ID": "Python.Python.3.12", "Name": "Python 3.12" },
            { "ID": "PuTTY.PuTTY", "Name": "PuTTY" },
            { "ID": "WinSCP.WinSCP", "Name": "WinSCP" },
            { "ID": "WinMerge.WinMerge", "Name": "WinMerge" },
            { "ID": "Git.Git", "Name": "Git" }
        ]
    },
    {
        "Name": "Dependencies",
        "Value": [
            { "ID": "abbodi1406.vcredist", "Name": "MS Visual C++ AIO" },
            { "ID": "Microsoft.DirectX", "Name": "DirectX" }
        ]
    },
    {
        "Name": "Documents",
        "Value": [
            { "ID": "Microsoft.Office", "Name": "Office 365" },
            { "ID": "Adobe.Acrobat.Reader.64-bit", "Name": "Adobe Acrobat Reader" },
            { "ID": "Foxit.FoxitReader", "Name": "Foxit PDF Reader" },
            { "ID": "TheDocumentFoundation.LibreOffice", "Name": "LibreOffice" },
            { "ID": "Kingsoft.WPSOffice.CN", "Name": "WPS Office" },
            { "ID": "Apache.OpenOffice", "Name": "OpenOffice" }
        ]
    },
    {
        "Name": "Imaging",
        "Value": [
            { "ID": "IrfanSkiljan.IrfanView", "Name": "IrfanView" },
            { "ID": "dotPDNLLC.paintdotnet", "Name": "Paint.NET" },
            { "ID": "GIMP.GIMP", "Name": "GIMP" },
            { "ID": "BlenderFoundation.Blender", "Name": "Blender" }
        ]
    },
    {
        "Name": "Messaging",
        "Value": [
            { "ID": "Discord.Discord", "Name": "Discord" },
            { "ID": "Microsoft.Skype", "Name": "Skype" },
            { "ID": "Mozilla.Thunderbird", "Name": "Thunderbird" },
            { "ID": "Zoom.Zoom", "Name": "Zoom" },
            { "ID": "9NKSQGP7F2NH", "Name": "WhatsApp" },
            { "ID": "Telegram.TelegramDesktop", "Name": "Telegram" }
        ]
    },
    {
        "Name": "Web Browsers",
        "Value": [
            { "ID": "Ablaze.Floorp", "Name": "Floorp" },
            { "ID": "Brave.Brave", "Name": "Brave" },
            { "ID": "Google.Chrome", "Name": "Google Chrome" },
            { "ID": "Mozilla.Firefox", "Name": "Firefox" },
            { "ID": "Vivaldi.Vivaldi", "Name": "Vivaldi" },
            { "ID": "Opera.Opera", "Name": "Opera" },
            { "ID": "Opera.OperaGX", "Name": "Opera GX" }
        ]
    },
    {
        "Name": "File Sharing",
        "Value": [
            { "ID": "qBittorrent.qBittorrent", "Name": "qBittorrent" },
            { "ID": "Tonec.InternetDownloadManager", "Name": "Internet Download Manager" },
            { "ID": "Transmission.Transmission", "Name": "Transmission" },
            { "ID": "CometNetwork.BitComet", "Name": "BitComet" },
            { "ID": "DelugeTeam.Deluge", "Name": "Deluge" },
            { "ID": "AppWork.JDownloader", "Name": "JDownloader 2" }
        ]
    },
    {
        "Name": "Media",
        "Value": [
            { "ID": "VideoLAN.VLC", "Name": "VLC Media Player" },
            { "ID": "CodecGuide.K-LiteCodecPack.Full", "Name": "K-Lite Codec Pack" },
            { "ID": "GOMLab.GOMPlayer", "Name": "GOM Player" },
            { "ID": "Spotify.Spotify", "Name": "Spotify" }
        ]
    },
    {
        "Name": "Gaming",
        "Value": [
            { "ID": "Valve.Steam", "Name": "Steam" },
            { "ID": "EpicGames.EpicGamesLauncher", "Name": "Epic Games Launcher" },
            { "ID": "Ubisoft.Connect", "Name": "Ubisoft Connect" }
        ]
    },
    {
        "Name": "Utilities",
        "Value": [
            { "ID": "TeamViewer.TeamViewer", "Name": "TeamViewer" },
            { "ID": "CodeSector.TeraCopy", "Name": "TeraCopy" },
            { "ID": "WinDirStat.WinDirStat", "Name": "WinDirStat" },
            { "ID": "Open-Shell.Open-Shell-Menu", "Name": "Open Shell" },
            { "ID": "Piriform.CCleaner", "Name": "CCleaner" },
            { "ID": "AntibodySoftware.WizTree", "Name": "WizTree" },
            { "ID": "Guru3D.Afterburner", "Name": "MSI Afterburner" },
            { "ID": "FxSoundLLC.FxSound", "Name": "FxSound" },
            { "ID": "HiBitSoftware.StartUpManager", "Name": "HiBit StartUp Manager" },
            { "ID": "HiBitSoftware.HiBitUninstaller", "Name": "HiBit Uninstaller" },
            { "ID": "RevoUninstaller.RevoUninstaller", "Name": "Revo Uninstaller" },
            { "ID": "Nilesoft.Shell", "Name": "Nilesoft Shell"}
        ]
    }
]
"@

$groupedApplications = $apps | ConvertFrom-Json

$categoryPerColumn = 3

$columnsNeeded = [math]::Floor($groupedApplications.Count / $categoryPerColumn)
$columnWidth = 200 # Define column width
$formWidth = $columnWidth * $columnsNeeded # Calculate form width based on columns needed

# Layout variables
$xPos = 10
$yPos = 10
$columnHeight = 0

# Create search box
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(($formWidth / 2), $yPos)
$searchBox.Size = New-Object System.Drawing.Size((($formWidth + 165) / 4), 20)
$searchBox.Text = Get-LocalizedText -key "Search"
$searchBox.Add_TextChanged({
    $searchText = $searchBox.Text.ToLower()
    # Check if the checkbox text contains the search text, if so, make the font bold
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Text.ToLower().Contains($searchText)) {
            $checkbox.Font = New-Object System.Drawing.Font($checkbox.Font, [System.Drawing.FontStyle]::Bold)
        } else {
            $checkbox.Font = New-Object System.Drawing.Font($checkbox.Font, [System.Drawing.FontStyle]::Regular)
        }
    }
})
$form.Controls.Add($searchBox)

$yPos += 30

# Create UI elements grouped by category and adjust for columns

$idx = 1
$checkboxes = @()

foreach ($group in $groupedApplications) {
    # Add category icon
    $image = Get-Image -url "https://raw.githubusercontent.com/emircankavas/kavasinstaller/main/icons/categories/$($group.Name).png"
    $icon = [System.Drawing.Image]::FromFile($image)
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Size(($xPos + 5), $yPos)
    $pictureBox.Size = New-Object System.Drawing.Size(20,20)
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Image = $icon
    $pictureBox.BackColor = [System.Drawing.Color]::Transparent
    $Form.controls.add($pictureBox)

    # Create a label for the category
    $label = New-Object System.Windows.Forms.Label
    $label.Text = Get-LocalizedText -key $group.Name
    $label.Location = New-Object System.Drawing.Point(($xPos + 25), $yPos)
    $label.AutoSize = $true
    $label.BackColor = [System.Drawing.Color]::Transparent
    $label.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($label)
    $yPos += 25

    # Create a checkbox for each application in the category
    foreach ($app in $group.Value) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $app.Name
        $checkbox.Tag = $app.ID # Use the Tag property to store the application ID
        $checkboxLoc = $xPos + 10
        $checkbox.Location = New-Object System.Drawing.Point($checkboxLoc, $yPos) # Indent checkboxes for visual grouping
        $checkbox.AutoSize = $true
        $checkbox.BackColor = [System.Drawing.Color]::Transparent
        $checkbox.ForeColor = [System.Drawing.Color]::White
        $form.Controls.Add($checkbox)
        $yPos += 20
        $checkboxes += $checkbox
    }

    $yPos += 10 # Add some space before the next category
    $columnHeight = [math]::Max($columnHeight, $yPos) # Track max column height
    # Increment column index after every second category
    # Reset yPos for each new column, and adjust xPos based on columnIndex
    if (($idx % $categoryPerColumn) -eq 0) {
        $xPos += $columnWidth
        $yPos = 40
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
$progressBarSize = $formWidth + 165
$progressBar.Size = New-Object System.Drawing.Size($progressBarSize, 10) # Span across the form width
$form.Controls.Add($progressBar)


# Initialize and place the label for current installing program above the progress bar
$installingLabel = New-Object System.Windows.Forms.Label
$installingLabelLocation = $yPos + 25
$installingLabel.Location = New-Object System.Drawing.Point(10, $installingLabelLocation) # Position above the progress bar
$installingLabel.Size = New-Object System.Drawing.Size($progressBarSize, 20) # Same width as the progress bar for alignment
$installingLabel.Text = Get-LocalizedText -key 'Waiting'

$installingLabel.BackColor = [System.Drawing.Color]::Transparent
$installingLabel.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($installingLabel)

# Update yPos for the progress bar based on the new label, adding space
$yPos += 20 # Adjust if needed based on actual layout

# Update yPos for the install button, adding space after the progress bar
$yPos += 50

# Initialize and center the install button below the progress bar
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = Get-LocalizedText -key 'Install'
$buttonInstallLocation = ($formWidth + 100) / 2 # Center the button
$buttonInstall.Location = New-Object System.Drawing.Point($buttonInstallLocation, $yPos) # Center the button
$buttonInstall.Size = New-Object System.Drawing.Size(100, 50)
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::GetFolderPath('System') + '\msiexec.exe')
$buttonInstall.Image = $icon.ToBitmap()

$buttonInstall.BackColor = [System.Drawing.Color]::Transparent
$buttonInstall.TextAlign = 'MiddleRight'
$buttonInstall.TextImageRelation = 'ImageBeforeText'
$buttonInstall.ForeColor = [System.Drawing.Color]::White
$buttonInstall.Font = New-Object System.Drawing.Font($buttonInstall.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonInstall)


# Add an event handler for the install button click
$buttonInstall.Add_Click({
    $buttonInstall.Enabled = $false
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
            winget.exe install $app.ID -e --accept-package-agreements
            $progressBar.PerformStep()
        }
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "Complete"))
        $installingLabel.Text = Get-LocalizedText -key "Complete"
    } else {
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "NoSelection"))
    }
    $buttonInstall.Enabled = $true
})

$form.Controls.Add($buttonInstall)

$form.Width = $formWidth + 200
$form.Height = $yPos + 100

$form.ShowDialog() | Out-Null