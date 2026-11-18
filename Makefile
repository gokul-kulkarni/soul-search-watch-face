# Build / simulate / sideload helpers for the Connect IQ watch face.
SDK_CFG := $(HOME)/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg
SDK     := $(shell cat "$(SDK_CFG)" 2>/dev/null)
DEVICE  ?= fr970
KEY     := keys/developer_key.der
OUT     := bin/GokulFace.prg

.PHONY: build sim run clean check-sdk install

check-sdk:
	@test -n "$(SDK)" || (echo "Connect IQ SDK not found. Install it with the SDK Manager first."; exit 1)

build: check-sdk
	@mkdir -p bin
	"$(SDK)/bin/monkeyc" -d $(DEVICE) -f monkey.jungle -o $(OUT) -y $(KEY) -w

sim: check-sdk
	"$(SDK)/bin/connectiq" &

run: build
	"$(SDK)/bin/monkeydo" $(OUT) $(DEVICE)

# Copy the build onto a USB-connected watch (USB Mode = MTP). Needs: brew install libmtp
MTP_TOOL := bin/mtp-install
$(MTP_TOOL): tools/mtp-install.c
	@mkdir -p bin
	cc -O2 -o $@ $< -I/opt/homebrew/include -L/opt/homebrew/lib -lmtp

install: build $(MTP_TOOL)
	-@pkill -f OpenMTP 2>/dev/null || true
	$(MTP_TOOL) $(OUT) GokulFace.prg

clean:
	rm -rf bin
