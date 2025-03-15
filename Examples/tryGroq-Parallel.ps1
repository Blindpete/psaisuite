# Import the PSAISuite module from the parent directory of the script's root directory
Clear-Host

$models = $(
    'gemma2-9b-it'
    'llama-3.3-70b-versatile'
    'llama-3.1-8b-instant'
    'llama-guard-3-8b'
    'llama3-70b-8192'
    'llama3-8b-8192'
    'mixtral-8x7b-32768'
    'qwen-qwq-32b'
    'mistral-saba-24b'
    'qwen-2.5-coder-32b'
    'qwen-2.5-32b'
    'deepseek-r1-distill-qwen-32b'
    'deepseek-r1-distill-llama-70b'
    'llama-3.3-70b-specdec'
    'llama-3.2-1b-preview'
    'llama-3.2-3b-preview'
    'llama-3.2-11b-vision-preview'
    'llama-3.2-90b-vision-preview'
)

$message = New-ChatMessage -Prompt "What is the capital of France?"

$models | ForEach-Object -Verbose -Parallel {
    # Import the PSAISuite module from the parent directory of the script's root directory since its not available in the parallel by default runs
    Import-Module $using:PSScriptRoot\..\PSAISuite.psd1 -Force 

    $model = $_
    Invoke-ChatCompletion $using:message groq:$model | Select-Object Model, Timestamp, Response
} 

''
"$($models.Count) models prompted."