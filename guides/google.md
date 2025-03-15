# Google

To use Google with `psaisuite` you will need to obtain a Google Gemini API key. Visit [Google AI Studio](https://makersuite.google.com/app/apikey) to create an API key if you don't already have one.

You'll need to set the following environment variable:

```powershell
$env:GeminiKey = "your-gemini-api-key"
```

## Create a Chat Completion

Install `psaisuite` from the PowerShell Gallery.

```powershell
Install-Module PSAISuite
```

In your code:

```powershell
# Import the module
Import-Module PSAISuite

$provider = "gemini"
$model_id = "gemini-1.5-pro"

# Create the model identifier
$model = "{0}:{1}" -f $provider, $model_id
$Message = New-ChatMessage -Prompt "What is the capital of France?"
Invoke-ChatCompletion -Message $Message -Model $model
```

```shell
Messages  : {"role":"user","content":"What is the capital of France?"}
Response  : Paris
            
Model     : gemini:gemini-1.5-pro
Provider  : gemini
ModelName : gemini-1.5-pro
Timestamp : Sun 03 09 2025 9:43:30 AM
```