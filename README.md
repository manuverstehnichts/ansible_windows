# Windows Ansible Playbook

Dieses Playbook automatisiert die Installation und Konfiguration deines Windows-PCs mit Ansible – schnell, effizient und wiederholbar.

<h3>WICHTIG</h3>
Bevor du dieses Repository nutzt, passe unbedingt die Inventory-Datei an deine Umgebung an. Ausserdem lösche die vorhandene vault.yml und erstelle eine neue, um deine eigenen geheimen Variablen sicher zu verwalten.

## Inhalt

- [Playbook-Funktionen](#playbook-funktionen)
- [Installation](#installation)
- [Windows-Host vorbereiten](#windows-host-vorbereiten)
- [Ansible-Steuerknoten einrichten](#ansible-steuerknoten-einrichten)
- [Nur bestimmte Aufgaben ausführen (Tags)](#nur-bestimmte-aufgaben-ausführen-tags)
- [Konfiguration per Variablen](#konfiguration-per-variablen)
- [Installierte Software (Standard)](#installierte-software-standard)

---

## Playbook-Funktionen

- **Software**
  - Entfernen von Bloatware
  - Installieren von Software via Chocolatey
  - Installieren von Software via WinGet
- **Windows Features**
  - Aktivieren optionaler Windows Features
  - Installieren und Konfigurieren von WSL2
  - Defragmentierung ausgewählter Volumes
- **Windows Einstellungen**
  - Taskbar anpassen
  - Startmenü entschlacken
  - Explorer konfigurieren
  - Desktop-Icons entfernen
  - Power-Plan setzen
  - Hostname ändern
  - Remote Desktop aktivieren
  - Windows Updates installieren
  - Mausbeschleunigung deaktivieren
  - Sound-Schema auf „Keine Sounds“ setzen
- **Terminal**
  - Oh My Posh mit Wunsch-Theme installieren

---

## Installation

### Windows-Host vorbereiten 🖥

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://gitlab.manu05.ch/manu/windows/-/raw/main/setup.ps1?ref_type=heads"
$file = "$env:temp\setup.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file -Verbose
```

### Ansible einrichten ⚙️

1. Python & Pip vorbereiten
2. Ansible installieren:

```bash
pip3 install --upgrade pip
pip3 install ansible
```

3. Repository klonen
4. Collections installieren:

```bash
ansible-galaxy install -r requirements.yml
```

5. `inventory`-Datei anpassen (Ziel-Windows-IP & Zugangsdaten via vault.yml)
6. Playbook starten:

```bash
ansible-playbook main.yml
```

---

## Nur bestimmte Aufgaben ausführen (Tags)

Beispiel: Nur Chocolatey & WSL installieren:

```bash
ansible-playbook main.yml --tags "chocolatey,defrag"
```

Verfügbare Tags:  

| Tag                | Beschreibung                                         |
| ------------------ | ---------------------------------------------------- |
| `hostname`         | Setzt den Hostnamen                                  |
| `background`       | Konfiguriert den Desktop-Hintergrund                 |
| `updates`          | Installiert Windows Updates                          |
| `debloat`          | Entfernt Bloatware                                   |
| `chocolatey`       | Installiert Chocolatey Pakete                        |
| `winget`           | Installiert Pakete via WinGet                        |
| `windows_features` | Installiert Windows Features                         |
| `wsl`              | Installiert WSL2 und konfiguriert die Distribution   |
| `fonts`            | Installiert Nerd Fonts                               |
| `ohmyposh`         | Installiert und konfiguriert Oh My Posh              |
| `explorer`         | Konfiguriert den Windows Explorer                    |
| `taskbar`          | Konfiguriert die Taskbar                             |
| `start_menu`       | Konfiguriert das Startmenü                           |
| `sounds`           | Setzt den Sound-Scheme                               |
| `mouse`            | Deaktiviert Mausbeschleunigung                       |
| `power`            | Konfiguriert den Energieplan                         |
| `remote_desktop`   | Aktiviert Remote Desktop                             |
| `desktop`          | Entfernt Desktop-Icons                               |
| `storage_sense`    | Konfiguriert Windows Storage Sense                   |
| `defrag`           | Führt Defragmentierung der angegebenen Volumes durch |

---

## Konfiguration per Variablen

Die Konfiguration erfolgt zentral über die Datei default.config.yml. Dort kannst du alle Einstellungen anpassen, um das Playbook nach deinen Wünschen zu steuern.

Möchtest du individuelle Werte für bestimmte Hosts setzen, kannst du alternativ in host_vars/<host>.yml Variablen überschreiben. Dieses muss jedoch selbst erstellt werden.

Beispiel-Konfiguration in default.config.yml:
```yml
configure_hostname: true
custom_hostname: mein-pc

remove_bloatware: true
bloatware:
  - Microsoft.Messaging

install_chocolatey_packages: true
choco_installed_packages:
  - name: git
    version: "2.37.1"
  - name: googlechrome
    state: latest
    choco_args: --ignorechecksum

install_windows_updates: true
update_categories:
  - Critical Updates
  - Security Updates

install_ohmyposh: true
ohmyposh_theme: agnoster
```
---

### Credits & Autor

This project was created by [Manuel Schär](https://github.com/manuverstehnichts) and is inspired by [Alex Nabokikh](https://github.com/AlexNabokikh/windows-playbook). Certain components have been adapted and incorporated.