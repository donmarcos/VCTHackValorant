import json
import re

# Define conversion functions for each event type (same as provided)


def convert_ability_used(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} | "
        f"Player ID: {event.get('PlayerId', 'Unknown Player')} used an ability with GUID {event.get('AbilityGuid', 'Unknown GUID')} "
        f"in slot {event.get('AbilitySlot', 'Unknown Slot')}, consuming {event.get('ChargesConsumed', 0)} charges during the "
        f"{event.get('GamePhase', 'Unknown Phase')} phase. Event occurred at {event.get('EventTime', 'Unknown Time')} "
        f"(wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


def convert_player_died(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} | Player ID: {event.get('DeceasedId', 'Unknown Deceased')} was killed by "
        f"Player ID {event.get('KillerId', 'Unknown Killer')} with weapon GUID {event.get('WeaponGuid', 'Unknown Weapon GUID')} "
        f"in the {event.get('GamePhase', 'Unknown Phase')} phase. Event occurred at {event.get('EventTime', 'Unknown Time')} "
        f"(wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


def convert_round_started(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} has started. Attacking Team Score: {event.get('SpikeMode_AttackingTeam', 'Unknown')} "
        f"vs. Defending Team Score: {event.get('SpikeMode_DefendingTeam', 'Unknown')} with {event.get('SpikeMode_RoundsToWin', 'Unknown')} "
        f"rounds needed to win. Phase: {event.get('GamePhase', 'Unknown Phase')}. Event occurred at {event.get('EventTime', 'Unknown Time')} "
        f"(wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


def convert_round_decided(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} was decided. Winning Team: {event.get('RoundResult_WinningTeam', 'Unknown Team')}, "
        f"Cause: {event.get('RoundResult_Cause', 'Unknown Cause')}. Phase: {event.get('GamePhase', 'Unknown Phase')}. "
        f"Event occurred at {event.get('EventTime', 'Unknown Time')} (wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


def convert_observer_target(event):
    text = (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Observer ID: {event.get('ObserverId', 'Unknown Observer')} | Target ID: {event.get('TargetId', 'Unknown Target')} "
        f"during the {event.get('GamePhase', 'Unknown Phase')} phase. Event occurred at {event.get('EventTime', 'Unknown Time')} "
        f"(wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )

    if "damageEvent" in event:
        damage_event = event["damageEvent"]
        text += (
            f" Observer observed damage: {damage_event.get('damageAmount', 'Unknown Amount')} damage dealt to location "
            f"{damage_event.get('location', 'Unknown Location')} with a {damage_event.get('weapon', {}).get('type', 'Unknown Weapon Type')}."
        )

    return text


def convert_damage_event(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} | Player ID {event.get('CauserId', 'Unknown Causer')} "
        f"dealt {event.get('DamageAmount', 'Unknown Amount')} damage to Player ID {event.get('VictimId', 'Unknown Victim')} "
        f"at {event.get('DamageLocation', 'Unknown Location')} with weapon GUID {event.get('WeaponGuid', 'Unknown Weapon')} "
        f"in the {event.get('GamePhase', 'Unknown Phase')} phase at {event.get('EventTime', 'Unknown Time')} "
        f"(wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


def convert_player_revived(event):
    return (
        f"Event: {event['EventType']} | Game ID: {event.get('GameId', 'Unknown Game ID')} | "
        f"Round: {event.get('RoundNumber', 'Unknown Round')} | Player ID {event.get('RevivedById', 'Unknown Reviver')} "
        f"revived Player ID {event.get('RevivedId', 'Unknown Revived')} during the {event.get('GamePhase', 'Unknown Phase')} phase. "
        f"Event occurred at {event.get('EventTime', 'Unknown Time')} (wall time: {event.get('WallTime', 'Unknown Wall Time')})."
    )


# Event dispatcher with all event types
event_dispatcher = {
    "abilityUsed": convert_ability_used,
    "playerDied": convert_player_died,
    "roundStarted": convert_round_started,
    "roundDecided": convert_round_decided,
    "observerTarget": convert_observer_target,
    "damageEvent": convert_damage_event,
    "playerRevived": convert_player_revived,
}

# Chunking logic
max_tokens = 3500  # Adjust as necessary for your LLM
token_count = 0
chunk = []

# Define output file path
output_file_path = "outputchunk\\outputchunkval.txt"
input_file_path = "outputjsonl\\testvalprocfile.json"

# Open the input JSON file and read the content
with open(input_file_path, "r") as file:
    content = file.read().strip()

    if content.startswith("[") and content.endswith("]"):
        content = content[1:-1].strip()

# Split the content into separate JSON objects based on curly braces
json_objects = re.findall(r"\{.*?\}", content)

# Open the output file for writing
with open(output_file_path, "w") as output_file:
    for line_number, line in enumerate(json_objects, start=1):
        # print(f"Processing line {line_number}: {line}")
        print(f"Processing line {line_number}")
        # Check for and remove trailing commas
        line = re.sub(r",\s*$", "", line)

        try:
            event = json.loads(line)
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e} for line {line_number}: {line}")
            continue  # Skip this line and continue with the next

        # Process the event based on its EventType
        event_type = event.get("EventType")
        if event_type in event_dispatcher:
            text = event_dispatcher[event_type](event)
            output_file.write(text + "\n")
        else:
            print(f"Unknown event type '{event_type}' in line {line_number}")

print(f"Processed events saved to {output_file_path}")
