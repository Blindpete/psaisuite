# Nebius AI Provider
<#
.SYNOPSIS
    Invokes the Nebius AI API to generate responses using specified models.

.DESCRIPTION
    The Invoke-NebiusProvider function sends requests to the Nebius AI API and returns the generated content.
    It requires an API key to be set in the environment variable 'NebiusKey'.

.PARAMETER ModelName
    The name of the Nebius model to use.

.PARAMETER Prompt
    The text prompt to send to the model.

.EXAMPLE
    $response = Invoke-NebiusProvider -ModelName 'yandexgpt' -Prompt 'Write a PowerShell function to calculate factorial'
    
.NOTES
    Requires the NebiusKey environment variable to be set with a valid API key.
    API Reference: https://nebius.ai/docs/yandexgpt/api-ref/
#>
function Invoke-NebiusProvider {
    param(
        [Parameter(Mandatory)]
        [string]$ModelName,
        [Parameter(Mandatory)]
        [string]$Prompt
    )
    
    $headers = @{
        'Authorization' = "Bearer $env:NebiusKey"
        'Content-Type'  = 'application/json'
    }
    
    $body = @{
        'model'    = $ModelName
        'messages' = @(
            @{
                'role'    = 'user'
                'content' = $Prompt
            }
        )
    }

    $Uri = "https://api.studio.nebius.ai/v1/chat/completions"

    $params = @{
        Uri     = $Uri
        Method  = 'POST'
        Headers = $headers
        Body    = $body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response.choices[0].message.content
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.ErrorDetails.Message
        Write-Error "Nebius AI API Error (HTTP $statusCode): $errorMessage"
        return "Error calling Nebius AI API: $($_.Exception.Message)"
    }
}