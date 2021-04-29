# 9NowDownloader
A PowerShell tool for batch downloading from 9Now.
This script takes a list of urls for TV Shows on the 9Now website and downloads any that haven't previous been downloaded.

# Requirements
[Selenium PowerShell Module](https://github.com/adamdriscoll/selenium-powershell) (From an admin shell - Install-Module Selenium)
[Youtube-DL](https://youtube-dl.org/)
[Selenium Chrome Driver](https://sites.google.com/chromium.org/driver/)

# Setup
* List the URL's for each show from the 9Now website in the showlist.csv file.
e.g. https://www.9now.com.au/lego-masters

* The youtube-dl.exe and chromedriver.exe can be placed within the 9NowDownloader folder. 
* If you have these installed elsewhere (preferably via [Chocolatey](https://chocolatey.org/install) so that can be easily updated) then update the $WebDriverDirectory line in the script to point to the correct location.

# Using
After adding URLs to showlist.csv, run *9nowDownloader.ps1* from a powershell window.

# TODO
Add a catchup option to mark all currently available episodes as previously downloaded. Then you could remove the lines that you do want from the downloadHistory.json file.
