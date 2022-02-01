defmodule MixUnused.Meta do
  @moduledoc """
  Metadata of the functions
  """

  @type t() :: %__MODULE__{
          signature: String.t(),
          file: String.t(),
          line: non_neg_integer(),
          doc_meta: map()
        }

  defstruct signature: nil, file: "nofile", line: 1, doc_meta: %{}
end
