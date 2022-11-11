# Mix Unused

[![Module Version](https://img.shields.io/hexpm/v/mix_unused.svg)](https://hex.pm/packages/mix_unused)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mix_unused/)
[![Total Download](https://img.shields.io/hexpm/dt/mix_unused.svg)](https://hex.pm/packages/mix_unused)
[![License](https://img.shields.io/hexpm/l/mix_unused.svg)](https://github.com/hauleth/mix_unused/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/hauleth/mix_unused.svg)](https://github.com/hauleth/mix_unused/commits/master)
[![CodeCov](https://codecov.io/gh/hauleth/mix_unused/branch/master/graph/badge.svg?token=936vbg6xv6)](https://codecov.io/gh/hauleth/mix_unused)

Mix compiler tracer for detecting unused public functions.

## Installation

```elixir
def deps do
  [
    {:mix_unused, "~> 0.3.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mix_unused](https://hexdocs.pm/mix_unused).

## Usage

After installation you need to add `:unused` as a compiler to the list of Mix
compilers:

```elixir
defmodule MySystem.MixProject do
  use Mix.Project

  def project do
    [
      compilers: [:unused] ++ Mix.compilers(),
      # In case of Phoenix projects you need to add it to the list
      # compilers: [:unused, :phoenix, :gettext] ++ Mix.compilers()
      # ...
      #
      # If you want to only run it in the dev environment you could do
      # it by using `compilers: compilers(Mix.env()) ++ Mix.compilers()`
      # instead and then returning the right compilers per environment.
    ]
  end

  # ...
end
```

Then you just need to run `mix compile` or `mix compile --force` as usual
and unused hints will be added to the end of the output.

### Cleaning your project

The tool keeps track of the calls traced during the compilation. The first time make sure that there is no compiled code:

```shell
mix clean
```

Doing so all the application code is recompiled and the calls are traced properly.

It is recommended to also perform a clean in the CI when the build does not start from a fresh project, for instance:

```shell
mix do clean, compile --all-warnings --warnings-as-errors
```

Please make sure you don't improperly override the clean task with an alias:

```elixir
def project do
  [
    # ⋯
    aliases: [
      # don't do this:
      clean: "deps.unlock --unused",

      # do this:
      clean: ["clean", "deps.unlock --unused"],
    ],
    # ⋯
  ]
end
```

### Warning

This isn't perfect solution and this will not find dynamic calls in form of:

```elixir
apply(mod, func, args)
```

So this mean that, for example, if you have custom `child_spec/1` definition
then `mix unused` can return such function as unused even when you are using
that indirectly in your supervisor.

This issue can be mitigated using the `Unreachable` check, explained below.

### Configuration

You can configure the tool using the `unused` options in the project configuration.
The following is the default configuration.

```elixir
def project do
  [
    # ⋯
    unused: [
      checks: [
        # find public functions that could be private
        MixUnused.Analyzers.Private,
        # find unused public functions
        MixUnused.Analyzers.Unused,
        # find functions called only recursively
        MixUnused.Analyzers.RecursiveOnly
      ],
      ignore: [],
      limit: nil,
      paths: nil,
      severity: :hint
    ],
    # ⋯
  ]
end
```

It supports the following options:

- `checks`: list of analyzer modules to use.

  In alternative to the default set, you can use the [MixUnused.Analyzers.Unreachable](`MixUnused.Analyzers.Unreachable`) check (see the specific [guide](guides/unreachable-analyzer.md)).

- `ignore`: list of ignored functions, example:

  ```elixir
  [
    {:_, ~r/^__.+__\??$/, :_},
    {~r/^MyAppWeb\..*Controller/, :_, 2},
    {MyApp.Test, :foo, 1..2}
  ]
  ```

  See the [Mix.Tasks.Compile.Unused](`Mix.Tasks.Compile.Unused`) task for further details.

- `limit`: max number of results to report (available also as the command option `--limit`).

- `paths`: report only functions defined in such paths.

  Useful to restrict the reported functions only to the functions defined in specific paths
  (i.e. set `paths: ["lib"]` to ignore functions defined in the `tests` folder).

- `severity`: severity of the reported messages.
  Allowed levels are `:hint`, `:information`, `:warning`, and `:error`.

## Copyright and License

Copyright © 2021 by Łukasz Niemier

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE](./LICENSE) file for more details.
