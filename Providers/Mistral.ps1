<#
.SYNOPSIS
    Invokes the Mistral API to generate responses using specified models.

.DESCRIPTION
    The Invoke-MistralProvider function sends requests to the Mistral API and returns the generated content.
    It requires an API key to be set in the environment variable 'MistralKey'.

.PARAMETER ModelName
    The name of the Mistral model to use (e.g., 'mistral-tiny', 'mistral-small', 'mistral-medium').

.PARAMETER Prompt
    The text prompt to send to the model.

.EXAMPLE
    $response = Invoke-MistralProvider -ModelName 'mistral-medium' -Prompt 'Write a PowerShell function to calculate factorial'
    
.NOTES
    Requires the MistralKey environment variable to be set with a valid API key.
    API Reference: https://docs.mistral.ai/api/
#>
function Invoke-MistralProvider {
    param(
        [Parameter(Mandatory)]
        [string]$ModelName,
        [Parameter(Mandatory)]
        [string]$Prompt
    )
    
    $headers = @{
        'Authorization' = "Bearer $env:MistralKey"        
        'content-type'  = 'application/json'
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

    $Uri = "https://api.mistral.ai/v1/chat/completions"
    
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
        Write-Error "Mistral API Error (HTTP $statusCode): $errorMessage"
        return "Error calling Mistral API: $($_.Exception.Message)"
    }
}