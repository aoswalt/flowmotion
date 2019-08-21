defmodule CounterWorkflow do
  @behaviour Flowmotion.Workflow

  alias Flowmotion.Next

  require Logger

  @impl Flowmotion.Workflow
  def new(count_arg) do
    count = if is_nil(count_arg), do: 0, else: count_arg

    Next.in_progress(%{count: count})
  end

  @impl Flowmotion.Workflow
  def step(:inc, state), do: step({:inc, 1}, state)

  def step({:inc, amount}, state) do
    state
    |> Map.update!(:count, &(&1 + amount))
    |> Next.in_progress()
  end

  def step(:dec, state), do: step({:dec, 1}, state)

  def step({:dec, _}, %{count: count} = state) when count <= 0 do
    Next.done(state)
  end

  def step({:dec, amount}, state) do
    state
    |> Map.update!(:count, &(&1 - amount))
    |> Next.in_progress()
  end

  def step(:boom, state) do
    Task.start(fn -> :timer.sleep(500); IO.puts("wake from nap") end)

    state
    |> Map.put(:reason, :boom)
    |> Next.errored()
  end

  @impl Flowmotion.Workflow
  def on_error(state) do
    Logger.warn("handling error")

    reason = Map.get(state, :reason)

    state
    |> Map.update(:history, [reason], & [reason | &1])
    |> Map.delete(:reason)
    |> Next.in_progress()
  end
end
