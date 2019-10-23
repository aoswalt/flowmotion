defmodule Flowmotion.VerboseWorkflow do
  alias Flowmotion.Next

  @type state :: map
  @type status :: :in_progress | :done | :errored

  @callback new(any) :: Next.t()

  @callback on_in(any, state) :: any
  @callback transition(any, state) :: Next.t()
  # NOTE(adam): what should this take and return? side-effects only? failable?
  @callback on_out(Next.t(), state) :: Next.t()

  @callback value(state) :: any

  @callback on_error(state) :: Next.t()

  @optional_callbacks on_error: 1, on_out: 2
end
