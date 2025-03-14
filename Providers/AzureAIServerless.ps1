<#
.SYNOPSIS
    Invokes the Azure AI Foundry Serverless API to generate responses using specified project.

.DESCRIPTION
    The Invoke-AzureAIServerlessProvider function sends requests to the Azure AI Foundry Serverless API and returns the generated content.
    It requires an API key to be set in the environment variable 'AzureAIServerlessKey' and an endpoint URL in 'AzureAIServflessEndpoint'.

.PARAMETER ModelName
    The name of the Azure AI model to use (e.g., 'phi-3.5', 'phi-4'). 
    Models available depend on your project configuration in Azure AI Foundry.

.PARAMETER Prompt
    The text messages to send to the model.

.EXAMPLE
    $response = Invoke-AzureAIServerlessProvider -ModelName 'phi-4' -Prompt 'Explain quantum computing'
    
.NOTES
    Requires the AzureAIServerlessKey environment variable to be set with a valid API key.
    Requires the AzureAIServflessEndpoint environment variable to be set with your Azure AI endpoint.
    API Reference: https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/deploy-models-serverless?tabs=azure-ai-studio#use-the-serverless-api-endpoint
#>
function Invoke-AzureAIServerlessProvider {
    param(
        [Parameter(Mandatory)]
        [string]$ModelName,
        [Parameter(Mandatory)]
        [string]$messages 
    )



    if (-not $env:AzureAIServerlessKey) {
        throw "Azure AI Serverless API key not found. Please set the AzureAIKey environment variable."
    }
    
    if (-not $env:AzureAIServflessEndpoint) {
        throw "Azure AI Serverless endpoint not found. Please set the AzureAIEndpoint environment variable."
    }
    

    $apiKey = $env:AzureAIServerlessKey
    $endpoint = $env:AzureAIServflessEndpoint.TrimEnd('/')
    
    # Construct the body to match the format in the CURL command
    $body = @{
        'messages'          = @(
            @{
                'role'    = 'user'
                'content' = $messages 
            }
        )
        'max_tokens'        = 2048
        'temperature'       = 0.8
        'top_p'             = 0.1
        'presence_penalty'  = 0
        'frequency_penalty' = 0
        'model'             = $ModelName
    }
    
    # Use the direct endpoint format from the CURL command
    $Uri = "$endpoint/chat/completions"
    
    $params = @{
        Uri     = $Uri
        Method  = 'POST'
        Headers = @{
            'Authorization' = "Bearer $apiKey"
            'Content-Type' = 'application/json'
        }
        Body    = $body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response.choices[0].message.content
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.ErrorDetails.Message
        Write-Error "Azure AI API Error (HTTP $statusCode): $errorMessage"
        return "Error calling Azure AI API: $($_.Exception.Message)"
    }
}