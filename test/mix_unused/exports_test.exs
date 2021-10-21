defmodule MixUnused.ExportsTest do
  use ExUnit.Case, async: true

  @subject MixUnused.Exports

  doctest @subject
end
