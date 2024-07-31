Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load shell32.dll and extract the icon
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Shell32
{
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr ExtractIcon(IntPtr hinst, string lpszExeFileName, int nIconIndex);
}
"@


$appVersion = "0.9"

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
        "Virtualization" = "Virtualization";
        "Security" = "Security";
        "Dependencices" = "Dependencies";
        "Title" = "Kavas Installer $appVersion";
        "Install" = "Install";
        "Complete" = "Installation Complete";
        "NoSelection" = "No applications selected.";
        "Waiting" = "Waiting for installation to start...";
        "Installing" = "Installing";
        "Search" = "Start typing to search";
        "wingetNotInstalled" = "winget is not installed. Please install it manually through the Microsoft Store by searching for 'App Installer' or check the documentation for your Windows version for alternative installation methods.";
        "Save" = "Save selected apps to JSON file";
        "Load" = "Load selected apps from JSON file";
        "Import" = "▼ Import";
        "Export" = "▲ Export";
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
        "Virtualization" = "Sanallaştırma";
        "Security" = "Güvenlik";
        "Dependencies" = "Bağımlılıklar";
        "Title" = "Kavas Yükleyici $appVersion";
        "Install" = "Yükle";
        "Complete" = "Yükleme Tamamlandı";
        "NoSelection" = "Hiçbir uygulama seçilmedi.";
        "Waiting" = "Yüklemenin başlaması bekleniyor...";
        "Installing" = "Yükleniyor";
        "Search" = "Aramak için yazmaya başlayın";
        "wingetNotInstalled" = "winget yüklü değil. Lütfen 'App Installer' uygulamasını Microsoft Store'dan arayarak manuel olarak yükleyin veya alternatif yükleme yöntemleri için Windows sürümünüzün belgelerine bakın.";
        "Save" = "Seçilen uygulamaları JSON'a kaydet";
        "Load" = "Seçilen uygulamaları JSON'dan yükle";
        "Import" = "▼ İçe Aktar";
        "Export" = "▲ Dışa Aktar";
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

function Save-File($selectedApps) {
    # Create a new SaveFileDialog object
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

    # Set the properties of the SaveFileDialog
    $saveFileDialog.Title = "Save File"
    $saveFileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
    $saveFileDialog.DefaultExt = "txt"
    $saveFileDialog.AddExtension = $true

    if ($saveFileDialog.ShowDialog() -eq 'OK') {
        # Save the selected applications to the file
        Write-Output $selectedApps | ConvertTo-Json | Out-File -FilePath $saveFileDialog.FileName
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
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = 'None'


$url = "https://preview.redd.it/w0qg2oanfel51.png?width=1080&crop=smart&auto=webp&s=46e6727910dc87c062f10ea077f2485d70eb428f"
$backgroundImage = $(Get-Image -url $url)

$form.BackgroundImage = [System.Drawing.Image]::FromFile($backgroundImage)
$form.BackgroundImageLayout = 'Stretch'

# Create the close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "x"
$closeButton.ForeColor = 'Gray'
$closeButton.BackColor = 'Red'
$closeButton.Width = 15
$closeButton.Height = 15
$closeButton.Location = New-Object System.Drawing.Point(10, 10)
$closeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$closeButton.FlatAppearance.BorderSize = 0
$closeButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8.25, [System.Drawing.FontStyle]::Bold)
$closeButton.Region = New-Object System.Drawing.Region([System.Drawing.Drawing2D.GraphicsPath]::new())
$closeButton.Region.MakeInfinite()
$closeButton.Region.Exclude([System.Drawing.Rectangle]::new(0, 0, 20, 20))
$closeButton.Region.Exclude([System.Drawing.Rectangle]::new(1, 1, 18, 18))
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(0, 0, $closeButton.Width, $closeButton.Height)
$closeButton.Region = New-Object System.Drawing.Region($path)
$closeButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($closeButton)

# Create the minimize button
$minimizeButton = New-Object System.Windows.Forms.Button
$minimizeButton.Text = "-"
$minimizeButton.ForeColor = 'Gray'
$minimizeButton.BackColor = 'Orange'
$minimizeButton.Width = 15
$minimizeButton.Height = 15
$minimizeButton.Location = New-Object System.Drawing.Point(30, 10)
$minimizeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$minimizeButton.FlatAppearance.BorderSize = 0
$minimizeButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 8.25, [System.Drawing.FontStyle]::Bold)
$minimizeButton.Region = New-Object System.Drawing.Region([System.Drawing.Drawing2D.GraphicsPath]::new())
$minimizeButton.Region.MakeInfinite()
$minimizeButton.Region.Exclude([System.Drawing.Rectangle]::new(0, 0, 20, 20))
$minimizeButton.Region.Exclude([System.Drawing.Rectangle]::new(1, 1, 18, 18))
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(0, 0, $minimizeButton.Width, $minimizeButton.Height)
$minimizeButton.Region = New-Object System.Drawing.Region($path)
$minimizeButton.Add_Click({
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})
$form.Controls.Add($minimizeButton)

# Create a label for the title
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = Get-LocalizedText -key 'Title'
$titleLabel.Location = New-Object System.Drawing.Point(60, 10)
$titleLabel.AutoSize = $true
$titleLabel.BackColor = [System.Drawing.Color]::Transparent
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object System.Drawing.Font($titleLabel.Font, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

$apps = @"
[   
    {
        "Name": "Compression",
        "Value": [
            { "ID": "7zip.7zip", "Name": "7-Zip" },
            { "ID": "Giorgiotani.Peazip", "Name": "PeaZip" },
            { "ID": "RARLab.WinRAR", "Name": "WinRAR" }
        ]
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
        "Name": "Virtualization",
        "Value": [
            { "ID": "Oracle.VirtualBox", "Name": "VirtualBox" },
            { "ID": "VMware.WorkstationPro", "Name": "VMware Workstation" },
            { "ID": "Docker.DockerDesktop", "Name": "Docker Desktop" },
            { "ID": "BlueStack.BlueStacks", "Name": "BlueStacks" }
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
    },
    {
        "Name": "Security",
        "Value": [
            { "ID": "9P6PMZTM93LR", "Name": "Microsoft Defender" },
            { "ID": "XPDNZJFNCR1B07", "Name": "Avast Free Antivirus" },
            { "ID": "XP8BX2DWV7TF50", "Name": "AVG AntiVirus Free" },
            { "ID": "Malwarebytes.Malwarebytes", "Name": "Malwarebytes" }
        ]
    }
]
"@

$groupedApplications = $apps | ConvertFrom-Json

$categoryPerColumn = 3

$columnsNeeded = [math]::Floor($groupedApplications.Count / $categoryPerColumn)
$columnWidth = 200 # Define column width
$formWidth = ($columnWidth * $columnsNeeded) # Calculate form width based on columns needed

# Layout variables
$xPos = 10
$yPos = 10
$columnHeight = 0

# Create search box
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBoxXPos = $formWidth
$searchBox.Location = New-Object System.Drawing.Point($searchBoxXPos, $yPos)
$searchBox.Size = New-Object System.Drawing.Size(180, 20)
#searchbox placeholder text
$searchBox.Text = Get-LocalizedText -key 'Search'

$searchBox.Add_TextChanged({
    $searchText = $searchBox.Text.ToLower()
    # if search text is empty, reset the font to regular
    if ($searchText -eq "") {
        foreach ($checkbox in $checkboxes) {
            # if font is already regular, skip
            if ($checkbox.Font.Bold -eq $false) {
                continue
            }
            $checkbox.Font = New-Object System.Drawing.Font($checkbox.Font, [System.Drawing.FontStyle]::Regular)
        }
    } else {
        # Check if the checkbox text contains the search text, if so, make the font bold
        foreach ($checkbox in $checkboxes) {
            if ($checkbox.Text.ToLower().Contains($searchText)) {
                $checkbox.Font = New-Object System.Drawing.Font($checkbox.Font, [System.Drawing.FontStyle]::Bold)
            } else {
                $checkbox.Font = New-Object System.Drawing.Font($checkbox.Font, [System.Drawing.FontStyle]::Regular)
            }
        }
    }

    
})
$form.Controls.Add($searchBox)

$yPos += 60

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
    $label.Font = New-Object System.Drawing.Font($label.Font, [System.Drawing.FontStyle]::Bold)
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
        $yPos = 70
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
            winget.exe install $app.ID --accept-package-agreements
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


# Add button which named "Load selected apps". It will load selected apps from a file.
$buttonLoad = New-Object System.Windows.Forms.Button
# Set button text
$buttonLoad.Text = Get-LocalizedText -key 'Import'

# transparent background and no border
$buttonLoad.BackColor = [System.Drawing.Color]::Transparent
$buttonLoad.ForeColor = [System.Drawing.Color]::White
$buttonLoad.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonLoad.FlatAppearance.BorderSize = 0


# Locate button to right of the search box
$buttonLoadXPos = $searchBoxXPos + 30
$buttonLoad.Location = New-Object System.Drawing.Point($buttonLoadXPos, ($yPos + 30))

$buttonLoad.Size = New-Object System.Drawing.Size(75, 24)
# Create the ToolTip
$toolTip = New-Object System.Windows.Forms.ToolTip

# Set up the delay for the tooltip (optional)
$toolTip.InitialDelay = 500
$toolTip.ReshowDelay = 100

# Set the tooltip text for the button
$toolTip.SetToolTip($buttonLoad, $(Get-LocalizedText -key 'Load'))

$buttonLoad.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Open File"
    $openFileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
    $openFileDialog.DefaultExt = "txt"
    $openFileDialog.AddExtension = $true

    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $selectedApps = Get-Content -Path $openFileDialog.FileName | ConvertFrom-Json
        foreach ($app in $selectedApps) {
            $form.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckBox] -and $_.Tag -eq $app.ID } | ForEach-Object {
                $_.Checked = $true
            }
        }
    }
})
$form.Controls.Add($buttonLoad)

# Add button which named "Save selected apps". It will save selected apps to a file.
$buttonSave = New-Object System.Windows.Forms.Button
# Set button text
$buttonSave.Text = Get-LocalizedText -key 'Export'

# Locate button to the right of load button
$buttonSaveLocation = $buttonLoadXPos + 70
$buttonSave.Location = New-Object System.Drawing.Point($buttonSaveLocation, ($yPos + 30))
$buttonSave.Size = New-Object System.Drawing.Size(90, 24)

# transparent background and no border
$buttonSave.BackColor = [System.Drawing.Color]::Transparent
$buttonSave.ForeColor = [System.Drawing.Color]::White
$buttonSave.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonSave.FlatAppearance.BorderSize = 0

# Create the ToolTip
$toolTip = New-Object System.Windows.Forms.ToolTip

# Set up the delay for the tooltip (optional)
$toolTip.InitialDelay = 500
$toolTip.ReshowDelay = 100

# Set the tooltip text for the button
$toolTip.SetToolTip($buttonSave, $(Get-LocalizedText -key 'Save'))


$buttonSave.Add_Click({
    $selectedApps = @()
    $form.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckBox] -and $_.Checked } | ForEach-Object {
        $selectedApp = @{ID = $_.Tag; Name = $_.Text}
        $selectedApps += $selectedApp
    }
    Write-Output $selectedApps
    Save-File -selectedApps $selectedApps
})
$form.Controls.Add($buttonSave)

# Add button which named "Recommended". It will select recommended apps.


$form.Width = $formWidth + 200
$form.Height = $yPos + 70

$form.ShowDialog() | Out-Null