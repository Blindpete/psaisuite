<#
.SYNOPSIS
Invokes a completion request to a specified AI model provider.

.DESCRIPTION
The Invoke-Completion function sends a prompt to a specified AI model provider and returns the completion response. 
The model provider and model name must be specified in the 'provider:model' format. The function dynamically constructs 
the provider-specific function name and invokes it to get the response.

.PARAMETER Prompt
The prompt string to be sent to the AI model for completion. This parameter is mandatory.

.PARAMETER Model
The model to be used for the completion request, specified in 'provider:model' format. Defaults to "openai:gpt-4o-mini".

.PARAMETER TextOnly
A switch parameter that, if specified, returns only the response text. If not specified, a custom object containing 
the response text, model information, and timestamp is returned.

.EXAMPLE
Invoke-Completion -Prompt "Hello, world!" -Model "openai:gpt-4o-mini"

Sends the prompt "Hello, world!" to the OpenAI GPT-4o-mini model and returns the completion response.

.EXAMPLE
Invoke-Completion -Prompt "Hello, world!" -Model "openai:gpt-4o-mini" -TextOnly

Sends the prompt "Hello, world!" to the OpenAI GPT-4o-mini model and returns only the completion response text.

.NOTES
The function dynamically constructs the provider-specific function name based on the provider specified in the Model 
parameter. If the provider function does not exist, an error is thrown.

#>
function Invoke-Completion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Model = "openai:gpt-4o-mini",
        [switch]$TextOnly
    )
    
    # Parse provider and model from the Model parameter
    if ($Model -match "^([^:]+):(.+)$") {
        $provider = $Matches[1].ToLower()
        $modelName = $Matches[2]
    }
    else {
        throw "Model must be specified in 'provider:model' format."
    }
    
    # Dynamically construct provider function name
    $providerFunction = "Invoke-${provider}Provider"
    
    # Check if the provider function exists
    if (-not (Get-Command $providerFunction -ErrorAction SilentlyContinue)) {
        throw "Unsupported provider: $provider. No function named $providerFunction found."
    }
    
    # Invoke the provider-specific implementation
    $responseText = & $providerFunction $modelName $Prompt
    
    # Return the result based on the TextOnly switch
    if ($TextOnly) {
        return $responseText
    }
    else {
        # Return a custom object with both the response and model information
        return [PSCustomObject]@{
            Response  = $responseText
            Model     = $Model
            Provider  = $provider
            ModelName = $modelName
            Timestamp = Get-Date
        }
    }
}
