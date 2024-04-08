# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/utils/player_activity_monitor.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

# Function to start the gameserver
function start_server() {
    log_success ">>> Starting the gameserver"

    pushd "${GAME_ROOT}" > /dev/null || exit

    START_OPTIONS=()
    if [[ -n ${COMMUNITY_SERVER} ]] && [[ ${COMMUNITY_SERVER,,} == "true" ]]; then
        log_info "> Setting Community-Mode to enabled"
        START_OPTIONS+=("-publiclobby")
    fi

    if [[ -n ${MULTITHREAD_ENABLED} ]] && [[ ${MULTITHREAD_ENABLED,,} == "true" ]]; then
        log_info "> Setting Multi-Core-Enhancements to enabled"
        START_OPTIONS+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
    fi

    if [[ -n $RCON_ENABLED ]] && [[ $RCON_ENABLED == "true" ]]; then
        log_info "> Setting RCON port on server start options"
        START_OPTIONS+=("-RCONPort=${RCON_PORT}")
    fi

    START_OPTIONS+=("-logformat=json")

    send_start_notification

    timestamp=$(date +%Y%m%d%H%M%S)

    if [ -f "${GAME_LOG_FILE}" ]; then
        mv "${GAME_LOG_FILE}" "${GAME_LOG_PATH}/${timestamp}_Palworld.log"
    fi

    touch "${GAME_LOG_FILE}"

    # Start the player activity monitor
    start_player_activity_monitor &

    ./PalServer.sh "${START_OPTIONS[@]}" | tee -a "${GAME_LOG_FILE}"

    popd > /dev/null || exit
}
