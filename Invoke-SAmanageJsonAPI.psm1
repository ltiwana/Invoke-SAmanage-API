Function Invoke-SAmanageJsonAPI {
    
    Param (        
        [int]$Results = 100,
        [Switch]$AllPages = $False,
        [string]$URI,        
        [string]$BearerToken,
        [string]$Method,
        $Body
    )

    [int]$i = 1
    [array]$APIdataJson = @()
    

    Write-Verbose "Info: Getting things ready for the API call"
    Write-Verbose "Info: Setting up JSON API header"
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
    $Headers.add("Content-Type", 'application/json')
    $Headers.Add("X-Samanage-Authorization", "Bearer $BearerToken")


    Write-Verbose "Making $Method API call"

    Switch ($Method) {

        Get {
            


            Write-Verbose "Action: Making first Get API call"

            $APIdata = Invoke-WebRequest -URI $URI -Method $Method -Headers $Headers -Verbose
            $APIdataJson += ConvertFrom-Json $APIdata

            $APITotalPages = $APIdata.Headers.'X-Total-Pages'

            Write-Verbose "Info: Checking API header for total number content pages"
            Write-Verbose "Info: $APITotalPages pages found"

            if ($APITotalPages -gt "1" -and $AllPages -eq $True) {
        
                Write-Verbose "Info: User requested all pages"
                Write-Verbose "Info: Getting results from each page"

                do {
                    
                    $i++

                    if ($VerbosePreference -eq "Continue") {
                       
                        $Percentage = [math]::Round($i/$APITotalPages*100)
                        Write-Progress -Activity ("Completed $i out of $APITotalPages") -Status "Current progress: $Percentage%"  -PercentComplete $Percentage
                    } 
            
                    
                    Write-Verbose "Info: Currently at page $i out $APITotalPages"
                    $NewURI = ($URI + "?page=$i")
                    Write-Verbose "Action: Making the the API call on $NewURI"
                    $APIdataJson += ConvertFrom-Json (Invoke-WebRequest -URI $NewURI -Method $Method -Headers $Headers -Verbose)

                } while ($i -ne $APITotalPages)


            }
    
            Write-Verbose "Info: API call completed"
            Write-Verbose "Info: Returning all the API data"
            return $APIdataJson

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
