Function Invoke-SAmanageJsonAPI {
    
    Param (        
        [cmdletbinding()]
        [string]$URI,        
        [string]$BearerToken,
        [string]$Method,
        $Body,
        [int]$Results = 100,
        [Switch]$Verbose,
        [Switch]$AllPages = $False
    )


    [int]$i = 1
    [array]$APIdataJson = @()
    

    Write-Verbose "Getting things ready for the API call"
    Write-Verbose "Setting up JSON API header"
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
    $Headers.add("Content-Type", 'application/json')
    $Headers.Add("X-Samanage-Authorization", "Bearer $BearerToken")

    
    Write-Verbose "Making $Method API call"

    Switch ($Method) {

        Get {
            


            Write-Verbose "Making first Get API call"

            $APIdata = Invoke-WebRequest -URI $URI -Method $Method -Headers $Headers -Verbose

            if ($APIdata -ne $null -or $APIdata) {
                $APIdataJson += ConvertFrom-Json $APIdata

                $APITotalPages = $APIdata.Headers.'X-Total-Pages'

                Write-Verbose "Checking API header for total number content pages"
                Write-Verbose "$APITotalPages pages found"

                if ($APITotalPages -gt "1" -and $AllPages -eq $True) {
        
                    Write-Verbose "User requested all pages"
                    Write-Verbose "Getting results from each page"

                    do {
                    
                        $i++

                        if ($VerbosePreference -eq "Continue") {
                       
                            $Percentage = [math]::Round($i/$APITotalPages*100)
                            Write-Progress -Activity ("Completed $i out of $APITotalPages") -Status "Current progress: $Percentage%"  -PercentComplete $Percentage
                        } 
            
                    
                        Write-Verbose "Currently at page $i out $APITotalPages"
                        $NewURI = ($APIdata.Headers.Link -split ";" -split ",")[0] -replace "\<" -replace "\>" -replace "page=1", "page=$i"
                        Write-Verbose "Making the the API call on $NewURI"
                        $APIdataJson += ConvertFrom-Json (Invoke-WebRequest -URI $NewURI -Method $Method -Headers $Headers -Verbose)

                    } while ($i -ne $APITotalPages)


                }
    
                Write-Verbose "API call completed"
                Write-Verbose "Returning all the API data"
                return $APIdataJson
            }
            Else {
                Write-Warning "API call returned no data"
            }

        }

        Put {
            
            if ($Body -eq $null -or !$body) {
                Write-Warning "Body is required to make Put API call"
                Write-Error "Body parameter was not used"
            }
            else {
                $APIdataJson += ConvertFrom-Json (Invoke-WebRequest -URI $URI -Headers $Headers -Method $Method -Body $BodyNull -Verbose)
                return $APIdataJson
            }

        }



    }


    
}
