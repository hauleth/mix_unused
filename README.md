# Mix Unused

Simple `mix` task that list all unused public functions in your project.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mix_unused` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mix_unused, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mix_unused](https://hexdocs.pm/mix_unused).

## Usage

Install and run `mix unused` and you will get list of all unused public
functions.

### Warning

This isn't perfect solution and this will not find dynamic calls in form of:

    apply(mod, func, args)

So this mean that, for example, if you have custom `child_spec/1` definition
then `mix unused` can return such function as unused even when you are using
that indirectly in your supervisor.

## Configuration

You can define used functions by adding `mfa` in `unused: [ignored: [⋯]]`
in your project configuration:

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

## Options

- `--exit-status` (default: false) - returns 1 if there are any unused function
calls
- `--quiet` (default: false) - do not print output
- `--compile` (default: true) - compile project before running

# License

See [LICENSE](LICENSE).
