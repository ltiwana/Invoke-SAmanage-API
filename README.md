# Invoke-SAmanage-API
Note: I will improve the instruction to keep an eye

This PowerShell module can help you make get or put API calls to SAManage ticketing system

Here are the variables that you can use or pass:
* Get all Incidents
* $APIURI = "https://api.samanage.com/incidents.json" 

* Method is Get or Put

* BearerToken is what you need to authenticate and here is how to get it: https://www.samanage.com/docs/api/introduction

* Use -AllPages to get unlimited results or get resuls from all available pages.

* Use -verbose to actually see what is happening behind the scenes.

By default the Invoke-SAmanageJsonAPI function returns JSON string and converts it into PowerShell object or table form.

### Usage:
Invoke-SAmanageJsonAPI -URI $APIURI -Method "Get" -BearerToken $BearerToken -AllPages -Verbose

### Results:
![alt text](/Screenshots/1.png)
