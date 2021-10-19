# Mix Unused

[![Module Version](https://img.shields.io/hexpm/v/mix_unused.svg)](https://hex.pm/packages/mix_unused)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mix_unused/)
[![Total Download](https://img.shields.io/hexpm/dt/mix_unused.svg)](https://hex.pm/packages/mix_unused)
[![License](https://img.shields.io/hexpm/l/mix_unused.svg)](https://github.com/hauleth/mix_unused/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/hauleth/mix_unused.svg)](https://github.com/hauleth/mix_unused/commits/master)


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
    ]
  end

  # ...
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

### Configuration

You can define used functions by adding `mfa` in `unused: [ignored: [⋯]]`
in your project configuration:

```elixir
def project do
  [
    # ⋯
    unused: [
      ignore: [
        {MyApp.Foo, :child_spec, 1}
      ]
    ],
    # ⋯
  ]
end
```

## Copyright and License

Copyright © 2021 by Łukasz Niemier

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
