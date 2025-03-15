$groqModels = $(
    'gemma2-9b-it'
    'llama-3.3-70b-versatile'
    'llama-3.1-8b-instant'
    'llama-guard-3-8b'
    'llama3-70b-8192'
    'llama3-8b-8192'
    'mixtral-8x7b-32768'
)

$message = New-ChatMessage -Prompt "capital of france"

$groqModels | ForEach-Object {
    Invoke-ChatCompletion $message "groq:$_"
} | Select-Object Model, Response