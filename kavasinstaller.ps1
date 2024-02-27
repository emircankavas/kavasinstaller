Add-Type -AssemblyName System.Windows.Forms

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
        "Title" = "Kavas Installer";
        "Install" = "Install";
        "Complete" = "Installation Complete";
        "NoSelection" = "No applications selected.";
        "Waiting" = "Waiting for installation to start...";
        "Installing" = "Installing";
    }
    "tr-TR" = @{
        "Compression" = "Sikistirma";
        "Development" = "Gelistirme";
        "Documents" = "Dokumanlar";
        "Imaging" = "Goruntuleme";
        "Messaging" = "Mesajlasma";
        "Web Browsers" = "Web Tarayicilar";
        "File Sharing" = "Dosya Paylasimi";
        "Media" = "Medya";
        "Gaming" = "Oyunlar";
        "Title" = "Kavas Yukleyici";
        "Install" = "Yukle";
        "Complete" = "Yukleme Tamamlandi";
        "NoSelection" = "Hiçbir uygulama secilmedi.";
        "Waiting" = "Yuklemenin baslamasi bekleniyor...";
        "Installing" = "Yukleniyor";
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
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'Adobe.Acrobat.Reader.64-bit'; Name = 'Adobe Acrobat Reader' },
    @{ Category = Get-LocalizedText -key 'Documents'; ID = 'TheDocumentFoundation.LibreOffice'; Name = 'LibreOffice' },
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
    @{ Category = Get-LocalizedText -key 'File Sharing'; ID = 'qBittorrent.qBittorrent'; Name = 'qBittorrent' },
    @{ Category = Get-LocalizedText -key 'File Sharing'; ID = 'Tonec.InternetDownloadManager'; Name = 'Internet Download Manager' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'VideoLAN.VLC'; Name = 'VLC Media Player' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'CodecGuide.K-LiteCodecPack.Full'; Name = 'K-Lite Codec Pack' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'GOMLab.GOMPlayer'; Name = 'GOM Player' },
    @{ Category = Get-LocalizedText -key 'Media'; ID = 'Spotify.Spotify'; Name = 'Spotify' },
    @{ Category = Get-LocalizedText -key 'Gaming'; ID = 'Valve.Steam'; Name = 'Steam' },
    @{ Category = Get-LocalizedText -key 'Gaming'; ID = 'EpicGames.EpicGamesLauncher'; Name = 'Epic Games Launcher' }
)

# Group applications by category
$groupedApplications = $applications | Group-Object Category

# Calculate the number of columns needed (max 2 categories per column)
$columnsNeeded = [math]::Floor($groupedApplications.Count / 2.0)
$columnWidth = 200 # Define column width
$formWidth = $columnWidth * $columnsNeeded # Calculate form width based on columns needed
$form.Size = New-Object System.Drawing.Size($formWidth, 600) # Set form size dynamically

# Layout variables
$xPos = 10
$yPos = 10
$columnHeight = 0
$columnIndex = 0

# Create UI elements grouped by category and adjust for columns
foreach ($group in $groupedApplications) {
    # Reset yPos for each new column, and adjust xPos based on columnIndex
    if ($columnIndex % 2 -eq 0 -and $columnIndex -ne 0) {
        $xPos += $columnWidth
        $yPos = 10
    }

    # Create a label for the category
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $group.Name
    $label.Location = New-Object System.Drawing.Point($xPos, $yPos)
    $label.AutoSize = $true
    $form.Controls.Add($label)
    $yPos += 20

    # Create a checkbox for each application in the category
    foreach ($app in $group.Group) {
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
    if (($groupedApplications.IndexOf($group) + 1) % 2 -eq 0) {
        $columnIndex++
    }
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
$progressBarSize = $formWidth - 20 # Subtract 20 for padding
$progressBar.Size = New-Object System.Drawing.Size($progressBarSize, 20) # Span across the form width
$form.Controls.Add($progressBar)


# Initialize and place the label for current installing program above the progress bar
$installingLabel = New-Object System.Windows.Forms.Label
$installingLabelLocation = $yPos - 20
$installingLabel.Location = New-Object System.Drawing.Point(10, $installingLabelLocation) # Position above the progress bar
$installingLabel.Size = New-Object System.Drawing.Size($progressBarSize, 20) # Same width as the progress bar for alignment
$installingLabel.Text = Get-LocalizedText -key 'Waiting'
$form.Controls.Add($installingLabel)

# Update yPos for the progress bar based on the new label, adding space
$yPos += 20 # Adjust if needed based on actual layout

# Update yPos for the install button, adding space after the progress bar
$yPos += 30

# Initialize and center the install button below the progress bar
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = Get-LocalizedText -key 'Install'
$buttonInstallLocation = ($formWidth -100) / 2 # Center the button
$buttonInstall.Location = New-Object System.Drawing.Point($buttonInstallLocation, $yPos) # Center the button
$buttonInstall.Size = New-Object System.Drawing.Size(100, 23)
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
            $installingLabel.Text = "$(Get-LocalizedText -key 'Installing'): $($app.Name)"
            
            # Simulate installation process (Replace with actual installation command)
            # Example: winget install $app.ID
            Start-Sleep -Seconds 2 # Simulate time taken for installation
            $progressBar.PerformStep()
        }
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "Complete"))
        $installingLabel.Text = "Installation Complete"
    } else {
        [System.Windows.Forms.MessageBox]::Show((Get-LocalizedText -key "NoSelection"))
    }
})

# Add the install button to the form
$form.Controls.Add($buttonInstall)

# Show the form
$form.ShowDialog()
