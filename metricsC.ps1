# Input and output file paths
$inputJsonlFile = "outputjsonl\testvalprocfile.json"
$outputMetricFile = "outputjsonl\testvalprocfile_with_metricsC.json"

# Clear or create the output file
if (Test-Path $outputMetricFile) {
    Clear-Content $outputMetricFile
}
else {
    New-Item -ItemType File -Path $outputMetricFile
}

"[" | Out-File -FilePath $outputMetricFile -Encoding utf8

# Load the JSONL content
$content = Get-Content -Path $inputJsonlFile -Raw | ConvertFrom-Json
Write-Host "File has : " + $content.Count + " events "

# Create an object to store player metrics by GameId
$gameMetrics = @{}
$eventCounter = 0

# Process each event and calculate metrics
foreach ($event in $content) {
    $eventCounter++
    Write-Host "Processing event $eventCounter of $($content.Count): $($event.EventType) for PlayerId: $($event.PlayerId)"

    $gameId = $event.GameId

    # Ensure a game-specific dictionary is created if it doesn't exist
    if (-not $gameMetrics.ContainsKey($gameId)) {
        $gameMetrics[$gameId] = @{
            "GameId"        = $gameId
            "PlayerMetrics" = @{}
        }
    }

    # Gather all player-related IDs
    $playerIds = @($event.PlayerId, $event.DeceasedId, $event.KillerId, $event.CauserId, $event.VictimId)
    
    foreach ($playerId in $playerIds) {
        if ($null -ne $playerId) {
            $playerIdStr = $playerId.ToString()

            # Initialize metrics if not present
            if (-not $gameMetrics[$gameId]["PlayerMetrics"].ContainsKey($playerIdStr)) {
                $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr] = @{
                    "TotalDamage"        = 0
                    "TotalAbilitiesUsed" = 0
                    "TotalKills"         = 0
                    "TotalDeaths"        = 0
                    "TotalAssists"       = 0
                    "KillsPerRound"      = @{}  # Initialize as a hashtable
                    "AttackKills"        = 0
                    "DefendKills"        = 0
                    "TotalHeadshots"     = 0
                    "SpikeDefuses"       = 0
                    "SpikePlants"        = 0
                }
            }
        }
    }

    # Process specific metrics based on event type
    switch ($event.EventType) {
        "damageEvent" {
            if ($null -ne $event.CauserId) {
                $playerIdStr = $event.CauserId.ToString()
                $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr]["TotalDamage"] += $event.DamageAmount
                if ($event.DamageLocation -eq "HEAD") {
                    $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr]["TotalHeadshots"] += 1
                }
            }
        }
        "abilityUsed" {
            if ($null -ne $event.PlayerId) {
                $playerIdStr = $event.PlayerId.ToString()
                $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr]["TotalAbilitiesUsed"] += 1
            }
        }
        "playerDied" {
            if ($null -ne $event.DeceasedId) {
                $deceasedIdStr = $event.DeceasedId.ToString()
                $gameMetrics[$gameId]["PlayerMetrics"][$deceasedIdStr]["TotalDeaths"] += 1
            }
            if ($null -ne $event.KillerId) {
                $killerIdStr = $event.KillerId.ToString()
                $gameMetrics[$gameId]["PlayerMetrics"][$killerIdStr]["TotalKills"] += 1
                
                # Track kills per round for consistency calculation
                if (-not $gameMetrics[$gameId]["PlayerMetrics"][$killerIdStr]["KillsPerRound"].ContainsKey($event.RoundNumber)) {
                    $gameMetrics[$gameId]["PlayerMetrics"][$killerIdStr]["KillsPerRound"][$event.RoundNumber.ToString()] = 0  # Key as string
                }
                $gameMetrics[$gameId]["PlayerMetrics"][$killerIdStr]["KillsPerRound"][$event.RoundNumber.ToString()] += 1  # Key as string
            }
        }
        "spikePlanted" {
            $playerIdStr = $event.PlayerId.ToString()
            $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr]["SpikePlants"] += 1
        }
        "spikeDefused" {
            $playerIdStr = $event.PlayerId.ToString()
            $gameMetrics[$gameId]["PlayerMetrics"][$playerIdStr]["SpikeDefuses"] += 1
        }
        # Add other event processing as needed, e.g., damageEvent, abilityUsed, etc.
    }
}

# Convert KillsPerRound keys to strings and output to JSON file with depth
foreach ($gameId in $gameMetrics.Keys) {
    # Ensure KillsPerRound keys are strings
    foreach ($playerId in $gameMetrics[$gameId]["PlayerMetrics"].Keys) {
        # Create a new hashtable to store the converted KillsPerRound
        $convertedKillsPerRound = @{}
        
        foreach ($roundKey in $gameMetrics[$gameId]["PlayerMetrics"][$playerId]["KillsPerRound"].Keys) {
            $convertedKillsPerRound[$roundKey.ToString()] = $gameMetrics[$gameId]["PlayerMetrics"][$playerId]["KillsPerRound"][$roundKey]
        }

        # Replace original KillsPerRound with the converted one
        $gameMetrics[$gameId]["PlayerMetrics"][$playerId]["KillsPerRound"] = $convertedKillsPerRound
    }
    
    $json = $gameMetrics[$gameId] | ConvertTo-Json -Compress -Depth 5  # Set depth to 5 for nested structures
    if ($gameMetrics.Keys[-1] -ne $gameId) {
        $json + "," | Out-File -FilePath $outputMetricFile -Encoding utf8 -Append
    }
    else {
        $json | Out-File -FilePath $outputMetricFile -Encoding utf8 -Append
    }
}

# Close the JSON array
"]" | Out-File -FilePath $outputMetricFile -Encoding utf8 -Append

Write-Host "Player metrics saved to $outputMetricFile grouped by GameId."

