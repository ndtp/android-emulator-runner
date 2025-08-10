#!/bin/bash

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;36m'
GREEN='\033[00;32m'

error()
{
    echo -e "${RED}[ERROR] ${1}${RESTORE}" >&2
}

warn()
{
    echo -e "${YELLOW}[WARNING] ${1} ${RESTORE}" >&2
}

info()
{
    echo -e "${BLUE}[INFO]${RESTORE} ${1}" >&2
}

success()
{
    echo -e "${GREEN}[SUCCESS]${RESTORE} ${1}" >&2
}

verbose()
{
    if [ "$verbose" == true ] || [ "$VERBOSE" == true ]; then
        warn "$1"
    fi
}

load_input_arguments()
{
    export avd_name="${1:-${AVD_NAME}}"
    export port="${2:-${EMULATOR_PORT}}"
    export boot_timeout="${3:-${EMULATOR_BOOT_TIMEOUT}}"
    export emulator_options="${4:-${EMULATOR_OPTIONS}}"
    export disable_animations="${5:-${DISABLE_ANIMATIONS}}"
    export disable_spellchecker="${6:-${DISABLE_SPELLCHECKER}}"
    export enable_hw_keyboard="${7:-${ENABLE_HW_KEYBOARD}}"
    export verbose="${8:-${VERBOSE}}"
}

verify_input_arguments()
{
    verbose "verify_input_arguments()"
    verbose "avd_name=$avd_name"
    verbose "port=$port"
    verbose "boot_timeout=$boot_timeout"
    verbose "emulator_options=$emulator_options"
    verbose "disable_animations=$disable_animations"
    verbose "disable_spellchecker=$disable_spellchecker"
    verbose "enable_hw_keyboard=$enable_hw_keyboard"
    verbose "verbose=$verbose"
}

wait_for_device() {
    local port="$1"
    local emulator_boot_timeout="$2"
    local retry_interval=2
    local max_attempts=$((emulator_boot_timeout / retry_interval))
    local attempts=0

    while true; do
        local result
        result=$(adb -s "emulator-${port}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n')
        if [ "$result" = "1" ]; then
            success "Emulator booted."
            break
        fi

        if [ "$attempts" -ge "$max_attempts" ]; then
            error "Timeout waiting for emulator to boot."
            return 1
        fi

        sleep "$retry_interval"
        attempts=$((attempts + 1))
    done
}

main()
{
    load_input_arguments "$@"

    if [ "$verbose" == true ] || [ "$VERBOSE" == true ]; then
        info "Verbose mode enabled"
    fi

    verify_input_arguments

    SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    verbose "SCRIPT_DIR: $SCRIPT_DIR"
    verbose "ANDROID_HOME: $ANDROID_HOME"

    echo "::group:: Starting Android Emulator"
    info "Starting Android Emulator with AVD '$avd_name' on port $port"
#    "$ANDROID_HOME/emulator/emulator" -port "$port" -avd "$avd_name" -no-window -gpu swiftshader_indirect -no-snapshot -noaudio -no-boot-anim &

    "$ANDROID_HOME/emulator/emulator" -port "$port" -avd "$avd_name" $emulator_options &

    if [ $? -ne 0 ]; then
        error "Failed to start the emulator."
        exit 1
    fi
    echo "::endgroup::"


    echo "::group:: Waiting for Emulator to start"
    info "Waiting up to $boot_timeout seconds for the emulator to start..."
    if ! wait_for_device "$port" $boot_timeout; then
        error "Emulator failed to start within timeout."
        exit 1
    fi
    info "Emulator started."
    info "Unlock the emulator screen if necessary."
    adb -s "emulator-$port" shell input keyevent 82
    echo "::endgroup::"

    echo "::group:: Configuring Emulator Settings"
    if [ "$disable_animations" == true ]; then
        info "Disabling animations."
        adb -s "emulator-$port" shell settings put global window_animation_scale 0.0
        adb -s "emulator-$port" shell settings put global transition_animation_scale 0.0
        adb -s "emulator-$port" shell settings put global animator_duration_scale 0.0
    fi

    if [ "$disable_spellchecker" == true ]; then
        info "Disabling spell checker."
        adb -s "emulator-$port" shell settings put secure spell_checker_enabled 0
    fi

    if [ "$enable_hw_keyboard" == true ]; then
        info "Enable hardware keyboard."
        adb -s "emulator-$port" shell settings put secure show_ime_with_hard_keyboard 0
    fi
    echo "::endgroup::"
}

main "$@"



