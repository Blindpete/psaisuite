# DeepSeek

To use DeepSeek with `psaisuite` you will need to [create an account](https://platform.deepseek.com). After logging in, go to the [API Keys](https://platform.deepseek.com/api_keys) section in your account settings and generate a new key. Once you have your key, add it to your environment as follows:

```shell
$env:DeepSeekKey = "your-deepseek-api-key"
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

$provider = "deepseek"
$model_id = "deepseek-chat"

# Create the model identifier
$model = "{0}:{1}" -f $provider, $model_id
$Message = New-ChatMessage -Prompt "What is the capital of France?"
Invoke-ChatCompletion -Message $Message -Model $model
```

```shell
Messages  : {"role":"user","content":"What is the capital of France?"}
Response  : The capital of France is **Paris**. Known for its rich history, iconic landmarks like the Eiffel Tower, and vibrant culture, Paris is one of the most famous cities in the 
            world.
Model     : deepseek:deepseek-chat
Provider  : deepseek
ModelName : deepseek-chat
Timestamp : Sun 03 09 2025 9:34:29 AM
```

You can also use DeepSeek's code models like `deepseek-coder` for programming tasks:

```powershell
Invoke-CodeCompletion -Prompt "Write a quick binary search function in PowerShell" -Model "deepseek:deepseek-coder"
```

```shell
Prompt    : Write a quick binary search function in PowerShell
Response  : Certainly! Below is a simple implementation of a binary search function in PowerShell:
            
            ```powershell
            function BinarySearch {
                param (
                    [int[]]$Array,
                    [int]$Target
                )
            
                $low = 0
                $high = $Array.Length - 1
            
                while ($low -le $high) {
                    $mid = [math]::Floor(($low + $high) / 2)
            
                    if ($Array[$mid] -eq $Target) {
                        return $mid  # Target found, return the index
                    } elseif ($Array[$mid] -lt $Target) {
                        $low = $mid + 1
                    } else {
                        $high = $mid - 1
                    }
                }
            
                return -1  # Target not found
            }
            
            # Example usage:
            $sortedArray = @(1, 3, 5, 7, 9, 11, 13, 15)
            $targetValue = 7
            
            $index = BinarySearch -Array $sortedArray -Target $targetValue
            
            if ($index -ne -1) {
                Write-Output "Target found at index $index"
            } else {
                Write-Output "Target not found"
            }
            ```
            
            ### Explanation:
            - **$Array**: The sorted array in which to search.
            - **$Target**: The value to search for.
            - **$low** and **$high**: The indices representing the current search range.
            - **$mid**: The middle index of the current search range.
            - The function returns the index of the target if found, otherwise it returns `-1`.
            
            ### Example Output:
            If you run the example provided, the output will be:
            ```
            Target found at index 3
            ```
            
            This indicates that the target value `7` was found at index `3` in the sorted array.
Model     : deepseek:deepseek-coder
Provider  : deepseek
ModelName : deepseek-coder
Timestamp : Sun 03 09 2025 9:35:18 AM
```