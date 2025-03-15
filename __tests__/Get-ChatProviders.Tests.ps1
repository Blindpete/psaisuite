BeforeAll {
    # Import the module to test
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    Import-Module "$ProjectRoot\PSAISuite.psd1" -Force
}

Describe "Get-ChatProviders" {
    It "Should return a list of provider names" {
        $providers = Get-ChatProviders
        $providers | Should -Not -BeNullOrEmpty
        $providers | Should -BeOfType [string]
    }

    It "Should return provider names that match files in the Providers directory" {
        $providers = Get-ChatProviders
        $expectedProviders = (Get-ChildItem -Path "$ProjectRoot\Providers" -Filter '*.ps1').BaseName
        $providers | Should -BeExactly $expectedProviders
    }

    It "Provider names should not include file extensions" {
        $providers = Get-ChatProviders
        $providers | ForEach-Object {
            $_ | Should -Not -BeLike "*.ps1"
        }
    }
}
