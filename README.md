# Numbers

An automatic [numbers station](https://en.wikipedia.org/wiki/Numbers_station) for OS X.

## What's a Numbers Station?

There's a fantastic [episode](http://99percentinvisible.org/episode/numbers-stations/) of [99% Invisible](http://99percentinvisible.org/) about numbers stations — it actually inspired me to make this.

If you don't want to listen for a 20 minute radio programme (though I highly recommend you do), there's always an [article](https://en.wikipedia.org/wiki/Numbers_station) on [Wikipedia](https://wikipedia.org).

## How it works

The numbers station outputs a number through the speakers every second. The numbers correspond to letters in a message in alphabetical order (A→1, B→2, etc.). _Real_ numbers stations encrypt their messages, but I want people who come across my numbers station to have a chance of actually figuring out the message I'm broadcasting. The message is customisable.

Once a message is completed, it will be followed by an optional, customisable chime sound, after which the message will start again.

Additionally, for the five seconds leading up to every hour, and on the hour itself, the station will halt message reading to sound the [Greenwich Time Signal](https://en.wikipedia.org/wiki/Greenwich_Time_Signal).

## Setting up

First, get a copy of the repository, either by `git clone` or by downloading from GitHub on the web.

### Download a compiled version

See the [Releases](https://github.com/alyssais/numbers/releases) page on GitHub to find a ready-to-use version.

### Compiling (short version)

1. Make sure [sox](http://sox.sourceforge.net) is installed. If you use Homebrew, you can install it with `brew install sox`.
2. Change into a directory containing the Numbers files.
3. Run `make`.

### Compiling (long version)

#### Compiling the executable

Run `make build/numbers` to create the Numbers executable at `build/numbers`.

#### Generating the voice sounds

Run `make build/sounds/numbers` to generate audio for each number 1 through 26 using OS X's built-in speech synthesis. You can use a custom voice like this:

```sh
make build/sounds/numbers VOICE=Samantha
```

#### Generating the flat tones

Flat 1 KHz tones are used by default for the chime between messages and the Greenwich Time Signal. [sox](http://sox.sourceforge.net) must be installed to use these.

Generate a 0.1 second 1 KHz tone:

```
make build/sounds/beep.wav
```

Generate a 1 second 1 KHz tone:

```
make build/sounds/longbeep.wav
```

## Usage

You will need a configuration file for the numbers station. The repository contains a file named config.example.json. Rename it to config.json for the software to load it automatically.

Change into the directory containing the compiled Numbers files, and run:

```sh
build/numbers
``` 

By default, Numbers will read configuration from a file named config.json in the current directory. This can be overridden like this:

```sh
build/numbers --config /path/to/custom_config.json
```

## Configuration

Numbers is configured using a JSON file with the following attributes:

<dl>
<dt>message</dt>
<dd>The message to broadcast.</dd>
<dt>tone</dt>
<dd>An array of names of sounds to play between messages. One sound is played each second (though sounds that last longer than a second will continue). `null` can be used to avoid a sound starting in a given second.</dd>
<dt>sounds</dt>
<dd><p>An object, where keys are names of sounds, and values are locations of the named sounds on disk.</p>
<p>The following sounds must be defined:</p>
<ul>
<li><code>1</code> through <code>26</code></li>
<li><code>beep</code></li>
<li><code>longbeep</code></li>
</ul>
<p>Other sounds can be used in the <code>tone</code> parameter.</p>
</dl>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alyssais/numbers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).
