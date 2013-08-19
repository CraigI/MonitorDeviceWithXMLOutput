MonitorLogFolders
=================
PowerShell Script used to a device that has an XML output. In my case this deviec as a Barracuda Spam and Virus Firewall.


Please see: http://it-erate.com/powershell-monitor-xml-output-device/ for further details on how to configure this script.


Main Files
=================
body.txt - this file get's created/changed as the script runs.
Devices.csv - contains the URL of the device and a short name which is used when writing out the alert.
MonitorDevicesXML.ps1 - PowerShell script that brings everything together. This script would need to be modified in order to monitor other
   types of XML output and those values would match up as defined in MonitorSettings.ini
MonitorSettings.ini - In my case it contains the values I want to alert on for the Barracuda Spam & Virus firewall. If the script is changed
   it would contain the different values of the XML attributes you want to alert on.


Usage
==================
In order to correctly monitor log folders you will need to either use a scheduled task or some other system that allows you to
run scripts on a scheduled interval.


About Us
=================
Please stop by and see other things we have going on at IT-erate.com. We hope that you found this script helpful and if so please stop by and
let us know!