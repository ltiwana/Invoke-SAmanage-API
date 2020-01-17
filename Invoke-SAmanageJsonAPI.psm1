Function Invoke-SAmanageJsonAPI {
    
    
    Param (        
        [cmdletbinding()]
        [Parameter(Position=0,Mandatory=$True)]
        [string]$URI,
        [Parameter(Position=0,Mandatory=$True)]
        [string]$Method,
        [Parameter(Position=2,Mandatory=$True)]
        [string]$BearerToken,
        $Body,
        [int]$Results = 100,
        [int]$Pages = 0,
        [int]$StartPage = 0,
        [int]$EndPage = 0,
        [Switch]$AllPages
    )


    [int]$i = 1
    [int]$j = 1
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

            $APIdata = Invoke-WebRequest -URI $URI -Method $Method -Headers $Headers -UseBasicParsing

            if ($APIdata -ne $null -or $APIdata) {
                $APIdataJson += ConvertFrom-Json $APIdata

                $APITotalPages = $APIdata.Headers.'X-Total-Pages'

                Write-Verbose "Checking API header for total number content pages"
                Write-Verbose "$APITotalPages pages found"
           
                if ($APITotalPages -gt "1" -and ($AllPages -eq $True -or $Pages -gt "1" -or (($StartPage -and $EndPage) -and $EndPage -gt 1))) {
                    
                    if ($AllPages) {Write-Verbose "User requested all pages"}
                    elseif ( $Pages -gt "1") {
                        Write-Verbose "User requested $Pages out of $APITotalPages pages"
                        $APITotalPages = $Pages
                    }
                    elseif ($StartPage -and $EndPage) {
                        Write-Verbose "User requested pages between $StartPage and $EndPage"
                        
                        if ($StartPage -gt 1) { 
                            $i = $StartPage - 1 
                            write-verbose "Discarding first page data"
                            $APIdataJson = $null

                        }
                        $APITotalPages = $EndPage
                        
                        
                    }

                    Write-Verbose "Getting results from request pages"

                    do {

                        $i++
                        $j++

                        if ($VerbosePreference -eq "Continue") {
                       
                            $Percentage = [math]::Round($j/$APITotalPages*100)
                            Write-Progress -Activity ("Completed $i out of $APITotalPages pages") -Status "Current progress: $Percentage%"  -PercentComplete $Percentage
                        } 

                        Write-Verbose "Currently at page $i out $APITotalPages"
                        $NewURI = ($APIdata.Headers.Link -split ";" -split ",")[0] -replace "\<" -replace "\>" -replace "page=1", "page=$i"
                        Write-Verbose "Making the the API call on $NewURI"
                        $APIdataJson += ConvertFrom-Json (Invoke-WebRequest -URI $NewURI -Method $Method -Headers $Headers -UseBasicParsing)

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
                $APIdataJson += ConvertFrom-Json (Invoke-WebRequest -URI $URI -Headers $Headers -Method $Method -Body $BodyNull -UseBasicParsing)
                return $APIdataJson
            }

        }



    }

    Write-Progress -Activity ("Completed $i out of $APITotalPages") -Status "Current progress: $Percentage%"  -Completed
    
}
