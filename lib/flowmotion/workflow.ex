defmodule Flowmotion.Workflow do
  alias Flowmotion.Next

  @type state :: map
  @type status :: :in_progress | :done | :errored

  @callback new(any) :: Next.t()
  @callback step(any, state) :: Next.t()

  @callback on_error(state) :: Next.t()

  @optional_callbacks on_error: 1
end
