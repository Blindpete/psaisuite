<#
.SYNOPSIS
Builds a chat message object based on the prompt and system role parameters.

.DESCRIPTION
The New-ChatMessage function builds a chat message object based on the prompt and system role parameters.
The chat message object is used to send a prompt to the AI model for completion. The system role parameter is optional.

.PARAMETER Prompt
The prompt string to be sent to the AI model for completion. This parameter is mandatory.

.EXAMPLE
New-ChatMessage -Prompt "Hello, world!"
Generate a message object with the user role and the prompt "Hello, world!".

.EXAMPLE
New-ChatMessage -Prompt "Hello, world!" -SystemRole "system" -SystemContent "you are a helpful PowerShell assistant, reply only with commands, hide codeblocks"
Generate a message object with the specified system role, system content and the prompt "Hello, world!".

.NOTES
The function dynamically constructs the chat message object based on the prompt and system role parameters.
If the system role parameter is specified, it is included in the chat message object.

#>

function New-ChatMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$SystemRole,
        [string]$SystemContent
    )

    $messages = @(
        if ($SystemRole) {
            @{
                'role'    = "$SystemRole"
                'content' = $SystemContent
            }
        }
        @{
            'role'    = 'user'
            'content' = $Prompt
        }
    )

    $messages

}