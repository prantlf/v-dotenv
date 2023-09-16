# .env file loader

Loads and strictly parses `.env` file contents, sets environment variables.

* Uses a [fast](bench/README.md) recursive descent parser written in V.
* Shows detailed [error messages](#errors) with location context.

## Synopsis

```go
import prantlf.dotenv { load_env }

load_env(true)!
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.dotenv
v install --git https://github.com/prantlf/v-dotenv
```

## API

The following types and functions are exported:

### LoadError

The following error will be thrown if a malformed file is loaded: 

```go
struct LoadError {
	reason string
	offset int
	line   int
	column int
}
```

```go
(e &LoadError) msg() string
(e &LoadError) msg_full() string
```

### load_env(overwrite bool) !bool

Loads and parses the contents of the file `.env` from the current directory, sets environment variables. Returns `true` if the file was found and processed. Returns `false` early, if the file wasn't found. If the argument `overwrite` is `true`, existing environment variables will be overwritten with values from the `.env` file, otherwise they will retain their previous values.

```go
import prantlf.dotenv { load_env }

load_env(true)!
```

### load_user_env(overwrite bool) !bool

Loads and parses the contents of the file `.env` from the user's home directory, sets environment variables. Returns `true` if the file was found and processed. Returns `false` early, if the file wasn't found. If the argument `overwrite` is `true`, existing environment variables will be overwritten with values from the `.env` file, otherwise they will retain their previous values.

```go
import prantlf.dotenv { load_user_env }

load_user_env(true)!
```

### load_file(file string, overwrite bool) !bool

Loads and parses the contents of the specified file from the current directory, sets environment variables. Returns `true` if the file was found and processed. Returns `false` early, if the file wasn't found. If the argument `overwrite` is `true`, existing environment variables will be overwritten with values from the specified file, otherwise they will retain their previous values.

```go
import prantlf.dotenv { load_env }

load_file('.env.local', true)!
```

## Errors

For example, loading a file with the following contents:

    answer

will fail with the following message, obtainable with `msg`:

    unexpected end encountered when parsing a property name on line 1, column 7

A longer and colourful message can ve obtained with `msg_full`:

    unexpected end encountered when parsing a property name:
    1 | answer
      |       ^

The message is formatted using the error fields, for example:

    LoadError {
      reason  string = 'unexpected end encountered when parsing a property name'
      offset  int    = 7
      line    int    = 1
      column  int    = 7
    }

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.dotenv
[original INI file format]: https://en.wikipedia.org/wiki/INI_file#Example
[INI file grammar]: ./doc/grammar.md#dotenv-file-grammar
