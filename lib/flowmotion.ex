defmodule Flowmotion do
  alias Flowmotion.{Instance, InstanceNotFoundError}
  alias Flowmotion.Storage.Ets, as: EtsStorage

  @spec start(module, any, module) :: Instance.t()
  def start(
        workflow_module,
        arg \\ nil,
        storage \\ default_storage()
      ) do
    storage.new_instance(workflow_module, arg)
  end

  @spec call(Instance.id(), any, module) :: {:ok, Instance.t()} | {:error, Exception.t()}
  def call(
        instance_id,
        message,
        storage \\ default_storage()
      ) do
    instance_id
    |> storage.get_instance()
    |> case do
      nil -> {:error, InstanceNotFoundError.exception(instance_id)}
      instance -> call_instance(message, instance, storage)
    end
  end

  @spec call_instance(any, Instance.t(), module) :: {:ok | :error, Instance.t()}
  defp call_instance(message, instance, storage) do
    cond do
      Instance.done?(instance) ->
        {:ok, instance}

      Instance.errored?(instance) ->
        {:error, instance}

      true ->
        next = Instance.call(instance, message)

        new_instance =
          instance
          |> Instance.update(next)
          |> handle_error()
          |> storage.save_instance()

        result = if Instance.errored?(new_instance), do: :error, else: :ok

        {result, new_instance}
    end
  end

  @spec handle_error(Instance.t()) :: Instance.t()
  defp handle_error(instance) do
    if Instance.errored?(instance) do
      Instance.on_error(instance)
    else
      instance
    end
  end

  @spec value(Instance.id(), module) :: any
  def value(instance_id, storage \\ default_storage()) do
    instance_id
    |> storage.get_instance()
    |> Instance.value()
  end

  @spec default_storage() :: module
  defp default_storage() do
    Application.get_env(:flowmotion, :storage_module, EtsStorage)
  end
end

defmodule Flowmotion.InstanceNotFoundError do
  defexception [:id, :message]

  def exception(id) do
    msg = "Workflow instance not found for id: #{id}"
    %__MODULE__{id: id, message: msg}
  end
end
