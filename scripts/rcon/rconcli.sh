#!/bin/bash
# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh

# Function to run RCON commands
# Arguments: <command>
# Example: rconcli "showplayers"
rconcli() {
    local cmd="$*"
    if [[ -z ${RCON_ENABLED+x} ]] || [[ "${RCON_ENABLED,,}" != "true" ]]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        return
    fi

    if [[ ! -f "${RCON_CONFIG_FILE}" ]]; then
        log_error ">>> RCON config file not found. Aborting RCON command ..."
        return
    fi

    if [[ ${cmd,,} == broadcast* ]]; then
        output=$(rcon -c "${RCON_CONFIG_FILE}" "${cmd}" | tr -d '\0')
        if [[ ${output} == Broadcasted:* ]]; then
            output="Broadcasted: ${cmd#broadcast }"
        fi
    else
        output=$(rcon -c "${RCON_CONFIG_FILE}" "${cmd}" | tr -d '\0')
    fi

    log_info -n "> RCON: "
    echo "$output"
}

rconcli "$*"
