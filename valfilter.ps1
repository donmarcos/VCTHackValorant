# Directory containing JSON files
$inputDirectory = "..\game-changers\games\2024\test"
# Path to output JSONL file
$outputJsonlFile = "outputjsonl\testvalprocfile.json"
# Path to jq filter file
$jqFilterFile = "valfilterA.jq"

# Ensure the output file exists and clear it if it does
if (Test-Path $outputJsonlFile) {
    Clear-Content $outputJsonlFile
}

# Write the opening bracket to the output file
"[`n" | Out-File -FilePath $outputJsonlFile -Encoding utf8 -NoNewline

# Initialize a counter for files processed
$counter = 1
# Get the total count of files to process
$totalFiles = (Get-ChildItem -Path $inputDirectory -Filter *.json).Count

# Process each JSON file in the input directory
Get-ChildItem -Path $inputDirectory -Filter *.json | ForEach-Object {
    $jsonFile = $_.FullName
    Write-Host "Processing file $counter of $totalFiles -- $jsonFile"
    
    # Run jq filter and capture the result
    $result = & jq -f -c $jqFilterFile $jsonFile

    # Split the result into individual JSON objects based on the closing brace
    $jsonObjects = $result -split '(?<=\})\s*(?=\{)'

    # Append each JSON object to the output file
    $lastIndex = $jsonObjects.Count - 1
    for ($i = 0; $i -lt $jsonObjects.Count; $i++) {
        $jsonObject = $jsonObjects[$i].Trim()
        if (-not [string]::IsNullOrWhiteSpace($jsonObject)) {
            # Append the JSON object
            Add-Content -Path $outputJsonlFile -Value $jsonObject
            
            # Add a comma and newline if not the last object
            if ($i -lt $lastIndex -or $counter -lt $totalFiles) {
                Add-Content -Path $outputJsonlFile -Value ",`n"
            }
        }
    }
    
    $counter++
}

# Write the closing bracket to the output file
"`n]" | Out-File -FilePath $outputJsonlFile -Encoding utf8 -Append
