defmodule CounterVerboseWorkflow do
  @behaviour Flowmotion.VerboseWorkflow

  alias Flowmotion.Next

  require Logger

  @impl Flowmotion.VerboseWorkflow
  def new(count_arg) do
    count = if is_nil(count_arg), do: 0, else: count_arg

    Next.in_progress(%{count: count})
  end

  @impl Flowmotion.VerboseWorkflow
  def on_in(:inc, state), do: on_in({:inc, 1}, state)
  def on_in({:inc, _} = inc, _state), do: inc
  def on_in(:dec, state), do: on_in({:dec, 1}, state)
  def on_in({:dec, _}, %{count: count}) when count <= 0, do: :done
  def on_in({:dec, _} = dec, _state), do: dec

  def on_in(:boom, _) do
    Task.start(fn ->
      :timer.sleep(500)
      IO.puts("wake from nap")
    end)

    :boom
  end

  @impl Flowmotion.VerboseWorkflow
  def transition({:inc, amount}, state) do
    state
    |> Map.update!(:count, &(&1 + amount))
    |> Next.in_progress()
  end

  def transition({:dec, amount}, state) do
    state
    |> Map.update!(:count, &(&1 - amount))
    |> Next.in_progress()
  end

  def transition(:done, state) do
    Next.done(state)
  end

  def transition(:boom, state) do
    state
    |> Map.put(:reason, :boom)
    |> Next.errored()
  end

  @impl Flowmotion.VerboseWorkflow
  def on_out(%{status: :errored} = next, %{reason: :boom}) do
    IO.puts("After it exploded")
    next
  end

  @impl Flowmotion.VerboseWorkflow
  def value(state) do
    state.count
  end

  @impl Flowmotion.VerboseWorkflow
  def on_error(state) do
    Logger.warn("handling error")

    reason = Map.get(state, :reason)

    state
    |> Map.update(:history, [reason], &[reason | &1])
    |> Map.delete(:reason)
    |> Next.in_progress()
  end
end
