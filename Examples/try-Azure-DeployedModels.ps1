# Import the PSAISuite module from the parent directory of the script's root directory
Import-Module $PSScriptRoot\..\PSAISuite.psd1 -Force

# Define the provider as 'azureai'
$provider = 'azureai'

# Define an array of deployed models
$deployedModels = 'gpt-4o', 'o1-mini', 'o3-mini'

$message = New-ChatMessage -Prompt "capital of France"

# Iterate over each model in the deployedModels array
$deployedModels | ForEach-Object {
    # Format the model slug by combining the provider and the model name
    $modelSlug = "{0}:{1}" -f $provider, $_
    
    # Invoke the completion function with the query "capital of France" message defined above and the model slug
    Invoke-ChatCompletion $message $modelSlug
}