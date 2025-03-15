<#
.SYNOPSIS
Gets the list of available AI chat providers in the PSAISuite module.

.DESCRIPTION
The Get-ChatProviders function lists all available AI providers from the Providers directory in the module.
This helps users understand which providers are installed and available for use with Invoke-ChatCompletion.

.EXAMPLE
Get-ChatProviders

Returns a list of all available AI providers in the PSAISuite module.

.NOTES
The function reads the files from the Providers directory and extracts just the provider names.
Each provider name corresponds to a provider implementation that can be used with Invoke-ChatCompletion.
#>
function Get-ChatProviders {
    [CmdletBinding()]
    param()

    # Find the module's Providers directory
    $ProvidersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Providers'
    
    # Get all provider files and extract just the names (without the .ps1 extension)
    $ProviderFiles = Get-ChildItem -Path $ProvidersPath -Filter '*.ps1' -ErrorAction SilentlyContinue
    
    # Return just the provider names (without extension)
    return $ProviderFiles.BaseName
}