#!/bin/bash

# shellcheck source=/dev/null
source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

function log_player_join() {
    local player_name=$1
    local player_uid=$2
    local player_steam_uid=$3

    log_info -n "> Player joined: " && log_base -n "'$player_name'" && \
    log_info -n " | UID: " && log_base -n "$player_uid" && \
    log_info -n " | Steam ID: " && log_base "$player_steam_uid"

    send_player_join_notification "\`$player_name\`" "$player_uid" "$player_steam_uid"
}

function log_player_left() {
    local player_name=$1
    local player_uid=$2
    local player_steam_uid=$3

    log_info -n "> Player left: " && log_base -n "'$player_name'" && \
    log_info -n " | UID: " && log_base -n "$player_uid" && \
    log_info -n " | Steam ID: " && log_base "$player_steam_uid"

    send_player_join_notification "\`$player_name\`" "$player_uid" "$player_steam_uid"
}

function start_player_activity_monitor() {

    if [[ "${PLAYER_MONITOR_ENABLED,,}" != "true" ]]; then
        log_warning ">> Player monitor is disabled."
        exit 1
    fi

    log_success ">>> Player activity monitor started"

    tail -f "${GAME_LOG_FILE}" | while read -r LOGLINE
    do
        # Check if the line is valid JSON and has an 'event' field
        if jq -e '.event' <<< "${LOGLINE}" > /dev/null 2>&1; then
            # process the line
            event=$(jq -r '.event' <<< "${LOGLINE}")
            if [[ "$event" == "join" ]]; then
                player_name=$(jq -r '.playername' <<< "${LOGLINE}")
                steam_id=$(jq -r '.userid' <<< "${LOGLINE}" | sed 's/^steam_//')
                user_id=$(steamid64_to_palworlduid "${steam_id}")

                log_player_join "${player_name}" "${user_id}" "${steam_id}"
            elif [[ "$event" == "left" ]]; then
                player_name=$(jq -r '.playername' <<< "${LOGLINE}")
                steam_id=$(jq -r '.userid' <<< "${LOGLINE}" | sed 's/^steam_//')
                user_id=$(steamid64_to_palworlduid "${steam_id}")

                log_player_left "${player_name}" "${user_id}" "${steam_id}"
            fi
        fi
    done
}
