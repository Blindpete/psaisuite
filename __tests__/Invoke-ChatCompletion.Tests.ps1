BeforeAll {
    # Import the module to test
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    Import-Module "$ProjectRoot\PSAISuite.psd1" -Force
}

Describe "New-ChatMessage" {
    It "Basic functionality" {
        $message = New-ChatMessage -Prompt "Test prompt"
        $message | Should -BeOfType [Hashtable]
        $message.role | Should -Be "user"
        $message.content | Should -Be "Test prompt"
    }

    It "With SystemRole functionality" {
        $message = New-ChatMessage -Prompt "Test prompt" -SystemRole system -SystemContent "you are a helpful powershell assistant, reply only with commands"
        $message | Should -BeOfType [Hashtable]
        $message[0].role | Should -Be "system"
        $message[0].content | Should -Be "you are a helpful powershell assistant, reply only with commands"
        $message[1].role | Should -Be "user"
        $message[1].content | Should -Be "Test prompt"
    }
}

Describe "Invoke-ChatCompletion" {
    BeforeEach {
        # Set up mocks for the provider functions in the PSAISuite module scope
        Mock -ModuleName PSAISuite Invoke-OpenAIProvider { param($model, $prompt) return "OpenAI Response: $prompt" }
        Mock -ModuleName PSAISuite Invoke-AnthropicProvider { param($model, $prompt) return "Anthropic Response: $prompt" }
    }

    Context "Basic functionality" {
        It "Returns text only when TextOnly switch is used" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message -TextOnly
            $result | Should -BeOfType [string]
            # Should -Invoke -ModuleName PSAISuite Invoke-OpenAIProvider -Times 1 -Exactly
        }

        It "Returns object by default" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message
            $result | Should -BeOfType [PSCustomObject]
            $result.Messages | Should -Be ($message | ConvertTo-Json -Compress)
            $result.Response | Should -Not -BeNullOrEmpty
            $result.Timestamp | Should -BeOfType [DateTime]
            # Should -Invoke -ModuleName PSAISuite Invoke-OpenAIProvider -Times 1 -Exactly
        }
    
        It "Uses default model when not specified" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message
            $result.Model | Should -Be "openai:gpt-4o-mini"
            # Should -Invoke -ModuleName PSAISuite Invoke-OpenAIProvider -Times 1 -Exactly -ParameterFilter { 
            #     $model -eq "gpt-4o-mini" -and $prompt -eq "Test prompt" 
            # }
        }

        It "Uses specified model when provided" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message -Model "anthropic:claude-3-sonnet-20240229"
            $result.Model | Should -Be "anthropic:claude-3-sonnet-20240229"
            $result.Provider | Should -Be "anthropic"
            $result.ModelName | Should -Be "claude-3-sonnet-20240229"
            # Should -Invoke -ModuleName PSAISuite Invoke-AnthropicProvider -Times 1 -Exactly -ParameterFilter {
            #     $model -eq "claude-3-sonnet-20240229" -and $prompt -eq "Test prompt"
            # }
        }
   
        It "Uses specified SystemRole when provided" {
            $message = New-ChatMessage -Prompt "Test prompt" -SystemRole "system" -SystemContent "you are a helpful powershell assistant, reply only with commands"
            $result = Invoke-ChatCompletion -Messages $message 
            $result | Should -BeOfType [PSCustomObject]
            $result.Messages | Should -Be ($message | ConvertTo-Json -Compress)
            $result.Response | Should -Not -BeNullOrEmpty
        }
    }

    Context "Elapsed time tracking" {
        It "Includes elapsed time in object when requested" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message -IncludeElapsedTime
            $result.ElapsedTime | Should -BeOfType [TimeSpan]
        }
    
        It "Includes elapsed time in text when TextOnly and IncludeElapsedTime are used" {
            $message = New-ChatMessage -Prompt "Test prompt"
            $result = Invoke-ChatCompletion -Messages $message -IncludeElapsedTime -TextOnly
            $result | Should -Match "Elapsed Time: \d{2}:\d{2}:\d{2}\.\d{3}"
        }
    }

    Context "Error handling" {
        It "Throws error for invalid model format" {
            $message = New-ChatMessage -Prompt "Test"
            { Invoke-ChatCompletion -Message $message -Model "invalid-model-format" } | 
            Should -Throw "Model must be specified in 'provider:model' format."
        }

        It "Throws error for nonexistent provider" {
            $message = New-ChatMessage -Prompt "Test"
            { Invoke-ChatCompletion -Message $message -Model "nonexistent:model" } | 
            Should -Throw "Unsupported provider: nonexistent. No function named Invoke-nonexistentProvider found."
        }
    }
}