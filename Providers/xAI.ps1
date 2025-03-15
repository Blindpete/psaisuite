<#
.SYNOPSIS
    Invokes the xAI API to generate responses using specified models.

.DESCRIPTION
    The Invoke-XAIProvider function sends requests to the xAI API and returns the generated content.
    It requires an API key to be set in the environment variable 'xAIKey'.

.PARAMETER ModelName
    The name of the xAI model to use (e.g., 'grok-1').

.PARAMETER Messages
    An array of hashtables containing the messages to send to the model.

.EXAMPLE
    $Message = New-ChatMessage -Prompt 'Explain quantum computing'
    $response = Invoke-XAIProvider -ModelName 'grok-1' -Message $Message
    
.NOTES
    Requires the xAIKey environment variable to be set with a valid API key.
    API Reference: https://docs.x.ai/
#>
function Invoke-XAIProvider {
    param(
        [Parameter(Mandatory)]
        [string]$ModelName,
        [Parameter(Mandatory)]
        [hashtable[]]$Messages
    )
    
    $headers = @{
        'Authorization' = "Bearer $env:xAIKey"
        'content-type'  = 'application/json'
    }
    
    $body = @{
        'model'    = $ModelName
        'messages' = $Messages
    }

    $Uri = "https://api.x.ai/v1/chat/completions"
    
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
        Write-Error "xAI API Error (HTTP $statusCode): $errorMessage"
        return "Error calling xAI API: $($_.Exception.Message)"
    }
}
