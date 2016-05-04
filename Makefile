.PHONY: build/sounds/numbers default

default: build/sounds build/numbers

build/numbers:
	xcodebuild -scheme numbers build CONFIGURATION_BUILD_DIR=build

build/sounds: build/sounds/numbers build/sounds/beep.wav build/sounds/longbeep.wav

MIN=1
MAX=26
VOICE=Alex
build/sounds/numbers:
	mkdir -p build/sounds
	for i in {${MIN}..${MAX}}; \
	do \
		say $$i -v ${VOICE} -o build/sounds/$$i.wav --data-format=LEF32@8000; \
	done

build/sounds/beep.wav:
	mkdir -p build/sounds
	sox -t null /dev/null build/sounds/beep.wav synth 0.1 sine 1000

build/sounds/longbeep.wav:
	mkdir -p build/sounds
	sox -t null /dev/null build/sounds/longbeep.wav synth 1 sine 1000
