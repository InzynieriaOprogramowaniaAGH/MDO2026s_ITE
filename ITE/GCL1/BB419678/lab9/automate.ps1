# Ustawienia
$VMName = "Fedora-Kickstart"
$ISOPath = "E:\_Install\Inne\linux_iso\Fedora-Server-netinst-x86_64-44-1.7.iso"  # <--- zmienna sciezka
$SwitchName = "Default Switch" # <--- mozemy także zmieniać switche do sieci

# Utworzenie nowej maszyny Generacji 2 z 2GB RAM i dyskiem 20GB
New-VM -Name $VMName -MemoryStartupBytes 2048MB -Generation 2 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Hard Disks\$VMName.vhdx" -NewVHDSizeBytes 20GB -SwitchName $SwitchName

# Skonfigurowanie Secure Boot pod Linuksa 
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# ISO fedory do instalacji
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# Kolejność bootowania systemu
$DVDDrive = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive

# Uruchomienie maszny
Start-VM -VMName $VMName

