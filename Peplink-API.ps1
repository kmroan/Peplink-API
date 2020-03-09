# API Documentation: https://www.peplink.com/ic2-api-doc/

# URI for all Peplink IC API interactions
$baseURI = "https://api.ic.peplink.com/rest"

function Get-PeplinkToken {
    param (
        [Parameter(Mandatory=$true)][string]$ClientID,
        [Parameter(Mandatory=$true)] [string]$ClientSecret
    )
    <#
        .SYNOPSIS
        Requests an authorization token for the peplink API and returns the access token, refresh token, and expiration. 

        .PARAMETER ClientID
        Client ID provided by Peplink

        .PARAMETER ClientSecret
        Secret key provided by Peplink 

        .Outputs
        Returns a System.Object.PSCustomObject with the Peplink access token.  

        .Example
        $token = Get-PeplinkToken -ClientID "dkdenzmyrlwqguej6s97rhed2q858vxif6ffg712uwnpy" -ClientScecret "om54u53evbt7eacz4y4hop0v7yimbkealgbrpmh0nrz6z"

    #>
    $pepURI = "https://api.ic.peplink.com/api/oauth2/token"
    $authData = "?client_id=$ClientID&client_secret=$ClientSecret&grant_type=client_credentials"
    $authHeaders = new-object "System.Collections.Generic.Dictionary[[String],[String]]"
    $authHeaders.Add("Content-Type","application/x-www-form-urlencoded")
    $authHeaders.Add("accept","application/json")
    $authHeaders =
    $token =  Invoke-RestMethod -Method Post -URI ($pepURI + $authData) -headers $authHeaders
    return $token
}

function Get-PeplinkOrganizations {
    param (
        [Parameter(Mandatory=$true)][string]$token
    )
        <#
        .SYNOPSIS
        Returns a list of organizations in Peplink InControl

        .PARAMETER Token   
         Access token for the Peplink InControl API

        .Outputs
        Returns a System.Object.PSCustomObject with the organization data. 

        .Example
        $peplink_Orgs = Get-PeplinkOrganizations -token $token.access_token

    #>
    $query = $baseURI + "/o?access_token=$token"

    try { 
        $response = Invoke-RestMethod -Method GET -URI $query
    } Catch {
        $exception = $_.Exception
        write-host "Error: $Exception"
        break 
    }
    return $response.data
}

function Get-PeplinkDeviceList {
    param (
        [Parameter(Mandatory=$true)][string]$token,
        [Parameter(Mandatory=$true)][string]$orgID,
        [Parameter()][ValidateSet('basic','full','csv')][string[]]$type = "basic"
    )
     <#
        .SYNOPSIS
        Returns a list of devices for the given Peplink organizational ID

        .PARAMETER Token   
         Access token for the Peplink InControl API

        .PARAMETER orgID
        Peplink organizational ID to query

        .PARAMETER type
        Get basic (faster) or full information, or a device list in CSV format. Refer to API documentation for more details. 
        The default value is Basic.

        .Outputs
        Full or Basic: Returns a System.Array with device data. 
        CSV: Returns a System.String with CSV data

        .Example
        $peplink_Devices = Get-PeplinkDeviceList -token $token.access_token -orgID "as12df3" -type "full"

    #>
    switch($type) {
        "basic" { 
            $pepURI = $baseURI + "/o/$orgID/d/basic"
            $query = $pepURI + "?organization_id=$orgID&access_token=$token"
        }

        "full" { 
            $pepURI = $baseURI + "/o/$orgID/d"
            $query = $pepURI + "?organization_id=$orgID&access_token=$token"
        }

        "csv" {
            $pepURI = $baseURI + "/o/$orgID/d/csv"
            $query = $pepURI + "?organization_ID=$orgID&access_token=$token"
         }
    }

    try { 
        $response = Invoke-RestMethod -Method GET -URI $query
    } Catch {
        $exception = $_.Exception
        write-host "Error: $Exception"
        break 
    }

    if ($type -eq "csv") { 
        return $response
    } else { 
        return $response.data
    }
}

Function Get-PeplinkDevice {
    param(
        [Parameter(Mandatory=$true)][string]$token,
        [Parameter(Mandatory=$true)][string]$orgID,
        [Parameter(Mandatory=$true)][string]$deviceID
    ) 
      <#
        .SYNOPSIS
        Returns information for a given Peplink device. 

        .PARAMETER Token   
         Access token for the Peplink InControl API

        .PARAMETER orgID
        Peplink organizational ID to query

        .PARAMETER deviceID
        ID of the devicee.

        .Outputs
        Returns a System.Object.PSCustomObject with the device data. 

        .Example
        $peplink_Device = Get-PeplinkDevice -token $token -orgid "asdf" -deviceid "78"

    #>   
    $pepURI = $baseURI + "/o/$orgID/d/$deviceID"
    $query = $pepURI + "?access_token=$token"

    try { 
        $response = Invoke-RestMethod -Method GET -URI $query
    } Catch {
        $exception = $_.Exception
        write-host "Error: $Exception"
        break 
    }

    return $response.data  
}
