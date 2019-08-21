defmodule Flowmotion.Storage.Ets do
  use GenServer

  alias Flowmotion.Instance

  @behaviour Flowmotion.Storage

  @table_name :flowmotion_instances

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, :ets.new(@table_name, [:named_table, :set, :public])}
  end

  @impl Flowmotion.Storage
  def new_instance(workflow_module, arg \\ nil) do
    new_id = :ets.info(@table_name, :size) + 1
    initial_next = workflow_module.new(arg)

    new_id
    |> Instance.new(workflow_module, initial_next)
    |> save_instance()
  end

  @impl Flowmotion.Storage
  def get_instance(instance_id) do
    case :ets.lookup(@table_name, instance_id) do
      [{^instance_id, instance}] -> instance
      [] -> nil
    end
  end

  @impl Flowmotion.Storage
  def save_instance(instance) do
    # NOTE(adam): ets insert returns true or raises
    id = Instance.id(instance)
    :ets.insert(@table_name, {id, instance})
    instance
  end
end
