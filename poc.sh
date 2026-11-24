#!/bin/sh
set -u

# Bootstrap: when launched as /tmp/app/bin/AppEngineerMode, copy self to persistent storage
# and re-exec DETACHED.
case "${0:-}" in
  */app/bin/AppEngineerMode)
    mkdir -p /rw_data/om 2>/dev/null
    SS=setsid; [ -x /usr/bin/setsid ] && SS=/usr/bin/setsid
    if cat "$0" > /rw_data/om/boot.sh 2>/dev/null; then chmod +x /rw_data/om/boot.sh 2>/dev/null
      "$SS" sh /rw_data/om/boot.sh run </dev/null >/dev/null 2>&1 &
      exit 0; fi ;;
esac

ROOT="${ROOT:-}"
[ "$(id -u)" = 0 ] || [ -n "$ROOT" ] || exit 1

# Optional: write the read-only /app rootfs. remount,rw + cp, else bind-mount. Not called by default.
apply_file(){ dst="$1"; src="$2"
  if mount -o remount,rw / 2>/dev/null && cp "$src" "${ROOT}$dst" 2>/dev/null; then
    command -v chsmack >/dev/null 2>&1 && chsmack -a _ "${ROOT}$dst" 2>/dev/null
    mount -o remount,ro / 2>/dev/null; return 0; fi
  mount --bind "$src" "${ROOT}$dst" 2>/dev/null; }


payload(){
	whoami
}

payload
