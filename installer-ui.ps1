Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallersPath = Join-Path $ScriptRoot 'installers'
$LogoPath = Join-Path $ScriptRoot 'assets/logo.png'

if (-not (Test-Path $InstallersPath)) {
    New-Item -Path $InstallersPath -ItemType Directory | Out-Null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'TIMNET | Format Sonrasi Hızlı Kurulum'
$form.Size = New-Object System.Drawing.Size(1020, 700)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(11, 11, 13)
$form.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(16, 14)
$headerPanel.Size = New-Object System.Drawing.Size(970, 140)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 23)
$form.Controls.Add($headerPanel)

$logoBox = New-Object System.Windows.Forms.PictureBox
$logoBox.Location = New-Object System.Drawing.Point(16, 10)
$logoBox.Size = New-Object System.Drawing.Size(220, 120)
$logoBox.SizeMode = 'Zoom'
$logoBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 23)
if (Test-Path $LogoPath) {
    $logoBox.Image = [System.Drawing.Image]::FromFile($LogoPath)
}
$headerPanel.Controls.Add($logoBox)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Format Sonrasi Tek Tık Kurulum'
$titleLabel.Location = New-Object System.Drawing.Point(250, 24)
$titleLabel.AutoSize = $true
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 204, 0)
$headerPanel.Controls.Add($titleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = 'USB > installers klasörüne attığınız EXE/MSI dosyaları burada listelenir ve sırayla kurulabilir.'
$subtitleLabel.Location = New-Object System.Drawing.Point(252, 72)
$subtitleLabel.Size = New-Object System.Drawing.Size(690, 40)
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(156, 160, 170)
$headerPanel.Controls.Add($subtitleLabel)

$listGroup = New-Object System.Windows.Forms.GroupBox
$listGroup.Text = 'Kurulabilir Paketler (installers klasörü)'
$listGroup.Location = New-Object System.Drawing.Point(16, 165)
$listGroup.Size = New-Object System.Drawing.Size(970, 250)
$listGroup.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($listGroup)

$installerList = New-Object System.Windows.Forms.CheckedListBox
$installerList.Location = New-Object System.Drawing.Point(16, 30)
$installerList.Size = New-Object System.Drawing.Size(936, 184)
$installerList.BackColor = [System.Drawing.Color]::FromArgb(27, 27, 32)
$installerList.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$installerList.CheckOnClick = $true
$listGroup.Controls.Add($installerList)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = 'Listeyi Yenile'
$btnRefresh.Location = New-Object System.Drawing.Point(16, 425)
$btnRefresh.Size = New-Object System.Drawing.Size(150, 35)
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(36, 36, 44)
$btnRefresh.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($btnRefresh)

$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = 'Tümünü Seç'
$btnSelectAll.Location = New-Object System.Drawing.Point(176, 425)
$btnSelectAll.Size = New-Object System.Drawing.Size(150, 35)
$btnSelectAll.BackColor = [System.Drawing.Color]::FromArgb(36, 36, 44)
$btnSelectAll.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($btnSelectAll)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = 'Seçilenleri Kur'
$btnInstall.Location = New-Object System.Drawing.Point(836, 425)
$btnInstall.Size = New-Object System.Drawing.Size(150, 35)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(255, 204, 0)
$btnInstall.ForeColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.Controls.Add($btnInstall)

$logGroup = New-Object System.Windows.Forms.GroupBox
$logGroup.Text = 'Terminal / Kurulum Günlüğü'
$logGroup.Location = New-Object System.Drawing.Point(16, 470)
$logGroup.Size = New-Object System.Drawing.Size(970, 180)
$logGroup.ForeColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$form.Controls.Add($logGroup)

$terminal = New-Object System.Windows.Forms.RichTextBox
$terminal.Location = New-Object System.Drawing.Point(16, 28)
$terminal.Size = New-Object System.Drawing.Size(936, 136)
$terminal.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 12)
$terminal.ForeColor = [System.Drawing.Color]::FromArgb(255, 204, 0)
$terminal.ReadOnly = $true
$terminal.Font = New-Object System.Drawing.Font('Consolas', 10)
$logGroup.Controls.Add($terminal)

function Write-Log([string]$Message) {
    $ts = (Get-Date).ToString('HH:mm:ss')
    $terminal.AppendText("[$ts] $Message`r`n")
    $terminal.ScrollToCaret()
}

function Get-InstallerFiles {
    Get-ChildItem -Path $InstallersPath -File -Include *.exe, *.msi | Sort-Object Name
}

function Refresh-InstallerList {
    $installerList.Items.Clear()
    $files = Get-InstallerFiles

    foreach ($file in $files) {
        $installerList.Items.Add($file.Name, $true) | Out-Null
    }

    if ($files.Count -eq 0) {
        Write-Log "installers klasöründe EXE/MSI bulunamadı: $InstallersPath"
    } else {
        Write-Log "$($files.Count) paket listelendi."
    }
}

$btnRefresh.Add_Click({
    Refresh-InstallerList
})

$btnSelectAll.Add_Click({
    for ($i = 0; $i -lt $installerList.Items.Count; $i++) {
        $installerList.SetItemChecked($i, $true)
    }
    Write-Log 'Tüm paketler seçildi.'
})

$btnInstall.Add_Click({
    $selected = @()

    foreach ($item in $installerList.CheckedItems) {
        $selected += [string]$item
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Lütfen en az bir kurulum dosyası seçin.', 'TIMNET', 'OK', 'Warning') | Out-Null
        return
    }

    $btnInstall.Enabled = $false
    $btnRefresh.Enabled = $false
    $btnSelectAll.Enabled = $false

    foreach ($name in $selected) {
        $path = Join-Path $InstallersPath $name
        if (-not (Test-Path $path)) {
            Write-Log "Atlandı (dosya yok): $name"
            continue
        }

        Write-Log "Kurulum başlatılıyor: $name"
        try {
            $proc = Start-Process -FilePath $path -WorkingDirectory $InstallersPath -PassThru
            $proc.WaitForExit()
            Write-Log "Kuruldu/Tamamlandı: $name | Çıkış Kodu: $($proc.ExitCode)"
        } catch {
            Write-Log "HATA: $name kurulamadı. $_"
        }
    }

    Write-Log 'Seçili kurulumlar tamamlandı.'

    $btnInstall.Enabled = $true
    $btnRefresh.Enabled = $true
    $btnSelectAll.Enabled = $true
})

Write-Log 'TIMNET hızlı kurulum arayüzü açıldı.'
Write-Log "installers klasörü: $InstallersPath"
if (-not (Test-Path $LogoPath)) {
    Write-Log 'Not: assets/logo.png bulunamadı. Logoyu bu yola kopyalayın.'
}
Refresh-InstallerList

[void]$form.ShowDialog()
