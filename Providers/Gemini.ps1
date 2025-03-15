<#
.SYNOPSIS
    Invokes the Google Gemini API to generate responses using specified models.

.DESCRIPTION
    The Invoke-GeminiProvider function sends requests to the Google Gemini API and returns the generated content.
    It requires an API key to be set in the environment variable 'GeminiKey'.

.PARAMETER ModelName
    The name of the Gemini model to use (e.g., 'gemini-1.0-pro', 'gemini-2.0-flash-exp').
    Note: Use the exact model name as specified by Google without any prefix.

.PARAMETER Messages
    An array of hashtables containing the messages to send to the model.

.EXAMPLE
    $Message = New-ChatMessage -Prompt 'Explain how CRISPR works'
    $response = Invoke-GeminiProvider -ModelName 'gemini-1.5-pro' -Message $Message
    
.NOTES
    Requires the GeminiKey environment variable to be set with a valid API key.
    The API key is passed as a URL parameter rather than in the headers.
    API Reference: https://ai.google.dev/gemini-api/docs
#>
function Invoke-GeminiProvider {
    param(
        [Parameter(Mandatory)]
        [string]$ModelName,
        [Parameter(Mandatory)]
        [hashtable[]]$Messages
    )
    
    if (-not $env:GeminiKey) {
        throw "Gemini API key not found. Please set the GeminiKey environment variable."
    }
    
    $apiKey = $env:GeminiKey
    
    foreach ($Msg in $Messages) {
        if ($Msg.role -eq 'system') {
            $SystemRole = $Msg.content
        }
        elseif ($Msg.role -eq 'user') {
            $Prompt = $Msg.content
        }
        else {
            throw "Invalid message role: $($Msg.role)"
        }
    }
   
    $body = @{
        'contents' = @(
            @{
                'role'  = 'user'
                'parts' = @(
                    @{
                        'text' = $Prompt
                    }
                )
            }
        )
    }
    
    if ($SystemRole) {
        $body['system_instruction'] = @{
            'parts' = @(
                @{
                    'text' = $SystemRole
                }
            )
        }
    }

    # Gemini uses the API key as a URL parameter
    # Fix model name - should be exactly as Google specifies (don't add prefix)
    # $Uri = "https://generativelanguage.googleapis.com/v1/models/$ModelName`:generateContent?key=$apiKey"
    
    $Uri = "https://generativelanguage.googleapis.com/v1beta/models/$($ModelName):generateContent?key=$apiKey"
    
    $params = @{
        Uri     = $Uri
        Method  = 'POST'
        Headers = @{'content-type' = 'application/json' }
        Body    = $body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        # Gemini has a different response structure
        return $response.candidates[0].content.parts[0].text
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.ErrorDetails.Message
        Write-Error "Gemini API Error (HTTP $statusCode): $errorMessage"
        return "Error calling Gemini API: $($_.Exception.Message)"
    }
}
