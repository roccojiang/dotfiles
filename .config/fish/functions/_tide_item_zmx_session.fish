function _tide_item_zmx_session
    set -q ZMX_SESSION; or return
    _tide_print_item zmx_session $tide_zmx_session_icon' ' "$ZMX_SESSION"
end
