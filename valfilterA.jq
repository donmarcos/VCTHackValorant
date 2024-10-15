.[] |
if .abilityUsed then
  {
    "EventType": "abilityUsed",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .metadata.currentGamePhase.roundNumber,
    "PlayerId": .abilityUsed.playerId.value,
    "AbilityGuid": .abilityUsed.ability.fallback.guid,
    "AbilitySlot": .abilityUsed.ability.fallback.inventorySlot.slot,
    "ChargesConsumed": .abilityUsed.chargesConsumed,
    "SpikeMode_AttackingTeam": null,
    "SpikeMode_DefendingTeam": null,
    "SpikeMode_RoundsToWin": null,
    "RoundResult_WinningTeam": null,
    "RoundResult_Cause": null,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .roundStarted then
  {
    "EventType": "roundStarted",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .roundStarted.roundNumber,
    "SpikeMode_AttackingTeam": .roundStarted.spikeMode.attackingTeam.value,
    "SpikeMode_AttackingTeam": .roundStarted.spikeMode.attackingTeam.value,
    "SpikeMode_RoundsToWin": .roundStarted.spikeMode.roundsToWin,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .roundDecided then
  {
    "EventType": "roundDecided",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .roundDecided.result.roundNumber,
    "RoundResult_WinningTeam": .roundDecided.result.winningTeam.value,
    "RoundResult_Cause": .roundDecided.result.spikeModeResult.cause,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .observerTarget then
  {
    "EventType": "observerTarget",
    "GameId": .metadata.gameId.value,
    "ObserverId": .observerTarget.observerId.value,
    "TargetId": .observerTarget.targetId.value,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .damageEvent then
  {
    "EventType": "damageEvent",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .metadata.currentGamePhase.roundNumber,
    "CauserId": .damageEvent.causerId.value,
    "VictimId": .damageEvent.victimId.value,
    "DamageAmount": .damageEvent.damageAmount,
    "DamageLocation": .damageEvent.location,
    "WeaponGuid": .damageEvent.weapon.fallback.guid,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .playerRevived then
  {
    "EventType": "playerRevived",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .metadata.currentGamePhase.roundNumber,
    "RevivedById": .playerRevived.revivedById.value,
    "RevivedId": .playerRevived.revivedId.value,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
elif .playerDied then
  {
    "EventType": "playerDied",
    "GameId": .metadata.gameId.value,
    "RoundNumber": .metadata.currentGamePhase.roundNumber,
    "DeceasedId": .playerDied.deceasedId.value,
    "KillerId": .playerDied.killerId.value,
    "WeaponGuid": .playerDied.weapon.fallback.guid,
    "GamePhase": .metadata.currentGamePhase.phase,
    "EventTime": .metadata.eventTime.includedPauses,
    "WallTime": .metadata.wallTime
  }
else
  empty
end
