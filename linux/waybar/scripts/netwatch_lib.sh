#!/usr/bin/env bash
# Shared scrape of the netwatch daemon's Prometheus endpoint.
# Linux port of sketchybar/plugins/netwatch_lib.sh — two changes:
#   * the cache lives in XDG_RUNTIME_DIR, not TMPDIR
#   * the default route comes from `ip route`, not `route -n get default`
# One curl per call; the caller greps what it needs out of NW_METRICS.

NW_ENDPOINT="${NW_ENDPOINT:-http://127.0.0.1:9464/metrics}"
NW_CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-netwatch.prom"

nw_scrape() {
  # 1.5s ceiling — the bar must never block on a sick daemon.
  if curl -sf --max-time 1.5 "$NW_ENDPOINT" -o "$NW_CACHE.tmp" 2>/dev/null; then
    mv -f "$NW_CACHE.tmp" "$NW_CACHE"
    NW_METRICS=$(cat "$NW_CACHE")
    return 0
  fi
  rm -f "$NW_CACHE.tmp"
  return 1
}

# nw_value <metric> [label-filter]
nw_value() {
  local metric="$1" filter="${2:-}"
  printf '%s\n' "$NW_METRICS" \
    | grep "^${metric}${filter}" \
    | head -1 \
    | awk '{print $NF}'
}

nw_primary_iface() {
  ip -4 route show default 2>/dev/null | awk '/^default/{print $5; exit}'
}

# Human-readable rate from bytes/sec.
nw_rate() {
  awk -v b="${1:-0}" 'BEGIN {
    if (b < 1024)            printf "%3dB", b;
    else if (b < 1048576)    printf "%3.0fK", b/1024;
    else if (b < 1073741824) printf "%3.1fM", b/1048576;
    else                     printf "%3.1fG", b/1073741824;
  }'
}

# Waybar wants one JSON object per interval on stdout.
nw_emit() {
  local text="$1" class="$2" tooltip="$3"
  jq -nc --arg t "$text" --arg c "$class" --arg tt "$tooltip" \
    '{text:$t, class:$c, tooltip:$tt}'
}
