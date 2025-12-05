#!/usr/bin/env sh
# Bootstrap script for the Coder agent with a local fallback.
# Based on provisionersdk/scripts/bootstrap_linux.sh (Coder OSS), but will try a
# local path and an alternate URL before the standard ACCESS_URL. Useful when
# the primary resolver/gateway is flaky (e.g., pfSense hiccups).

set -eux

waitonexit() {
	echo "=== Agent script exited with non-zero code ($?). Sleeping 24h to preserve logs..."
	sleep 86400
}
trap waitonexit EXIT

ARCH="${ARCH:-amd64}"
BINARY_DIR="${BINARY_DIR:-$(mktemp -d -t coder.XXXXXX)}"
BINARY_NAME=coder

# Primary URL from Coder ACCESS_URL, plus optional fallback IP (host LAN).
PRIMARY_URL="${ACCESS_URL}bin/coder-linux-${ARCH}"
FALLBACK_URL="${CODER_AGENT_FALLBACK_URL:-http://10.0.0.184/bin/coder-linux-${ARCH}}"

cd "$BINARY_DIR"

try_download() {
	url="$1"
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --compressed "$url" -o "$BINARY_NAME"
	elif command -v wget >/dev/null 2>&1; then
		wget -q "$url" -O "$BINARY_NAME"
	elif command -v busybox >/dev/null 2>&1; then
		busybox wget -q "$url" -O "$BINARY_NAME"
	else
		echo "error: no download tool found, please install curl, wget or busybox wget"
		return 127
	fi
}

# Keep retrying so the workspace doesn't fail hard if the gateway is down.
while :; do
	status=""

	# 1) Local/LAN URL (evita pfSense si 10.0.0.184 responde).
	if try_download "$FALLBACK_URL"; then
		break
	else
		status=$?
	fi

	# 2) Default URL via ACCESS_URL.
	if try_download "$PRIMARY_URL"; then
		break
	else
		status=$?
	fi

	echo "error: failed to download coder agent"
	echo "       command returned: ${status}"
	echo "Trying again in 30 seconds..."
	sleep 30
done

chmod +x "$BINARY_NAME"

haslibcap2() {
	command -v setcap /dev/null 2>&1
	command -v capsh /dev/null 2>&1
}
printnetadminmissing() {
	echo "The root user does not have CAP_NET_ADMIN permission. " + \
		"If running in Docker, add the capability to the container for " + \
		"improved network performance."
	echo "This has security implications. See https://man7.org/linux/man-pages/man7/capabilities.7.html"
}

if [ -n "${USE_CAP_NET_ADMIN:-}" ]; then
	if [ "$(id -u)" -eq 0 ]; then
		if ! capsh --has-p=CAP_NET_ADMIN; then
			printnetadminmissing
		fi
	elif sudo -nl && haslibcap2; then
		if sudo -n capsh --has-p=CAP_NET_ADMIN; then
			sudo -n setcap CAP_NET_ADMIN=+ep ./$BINARY_NAME || true
		else
			printnetadminmissing
		fi
	else
		echo "Unable to setcap agent binary. To enable improved network performance, " + \
			"give the agent passwordless sudo permissions and the \"setcap\" + \"capsh\" binaries."
		echo "This has security implications. See https://man7.org/linux/man-pages/man7/capabilities.7.html"
	fi
fi

export CODER_AGENT_AUTH="${AUTH_TYPE}"
export CODER_AGENT_URL="${ACCESS_URL}"

output=$(./${BINARY_NAME} --version | head -n1)
if ! echo "${output}" | grep -q Coder; then
	echo >&2 "ERROR: Downloaded agent binary returned unexpected version output"
	echo >&2 "${BINARY_NAME} --version output: \"${output}\""
	exit 2
fi

exec ./${BINARY_NAME} agent
