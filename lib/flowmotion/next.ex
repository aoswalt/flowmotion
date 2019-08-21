defmodule Flowmotion.Next do
  use TypedStruct

  alias __MODULE__
  alias Flowmotion.Workflow

  typedstruct opaque: true, enforce: true do
    field(:status, Workflow.status())
    field(:state, Workflow.state())
  end

  @spec state(t) :: Workflow.state()
  def state(next), do: next.state

  @spec status(t) :: Workflow.status()
  def status(next), do: next.status

  @spec in_progress(Workflow.state()) :: Next.t()
  def in_progress(state) when is_map(state) do
    %Next{status: :in_progress, state: state}
  end

  @spec errored(Workflow.state()) :: Next.t()
  def errored(state) when is_map(state) do
    %Next{status: :errored, state: state}
  end

  @spec done(Workflow.state()) :: Next.t()
  def done(state) when is_map(state) do
    %Next{status: :done, state: state}
  end
end
