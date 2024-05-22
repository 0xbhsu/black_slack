# black_slack
This script aims to help the installation process of pentesting tools and wordlists.

It was tested against Slackware-15.0 x86_64.

# Requirements
The script has some requirements to be executed correctly. The **sbopkg** requirement are to speed up tool compilation time and make the process more intuitive, even though it is possible to do everything manually. The requirements are:
- **[sbopkg](https://sbopkg.org/) (0.38.2)**: the slackbuilds.org package browser
- **Python (3.9.19)**
- **gem (3.2.33)**
- **git (2.39.4)**

With the exception of **sbopkg**, all other requirements are installed by default in Slackware-15.0.

# Usage
Edit the "**REGULAR_USER**" variable to match your everyday user and
```
./black_slack.sh [tools|wordlists|all]
```

# Tools
The script uses some variables to control the version of some specific tools, which can be changed to have a specific version running. All tools and requirements are listed below:
* metasploit-framework
    * postgresql required
* sqlmap
* netexec
    * pipx required
* impacket (version 0.9)
* wireshark
* crunch
* bloodhound
    * neo4j (version 4.4.33) required
        * zulu-openjdk11 required
* wafw00f
* subfinder
* evil-winrm
* wpscan
* gobuster
* ffuf
* burpsuite-pro
* hashcat
* john   

# Wordlists
[SecLists](https://github.com/danielmiessler/SecLists) and [rockyou.txt](https://gitlab.com/kalilinux/packages/wordlists/-/blob/kali/master/rockyou.txt.gz).
