defmodule Flowmotion do
  alias Flowmotion.{Instance, InstanceNotFoundError}
  alias Flowmotion.Storage.Ets, as: EtsStorage

  def start(
        workflow_module,
        arg \\ nil,
        storage \\ default_storage()
      ) do
    storage.new_instance(workflow_module, arg)
  end

  def call(
        instance_id,
        message,
        storage \\ default_storage()
      ) do
    instance = storage.get_instance(instance_id)

    if instance do
      module = Instance.workflow_module(instance)
      state = Instance.state(instance)

      next = module.step(message, state)

      # next = Instance.call_workflow(instance, message)

      new_instance = Instance.update(instance, next)

      handled_instance =
        if Instance.errored?(new_instance) and function_exported?(module, :on_error, 1) do
          handled_next =
            new_instance
            |> Instance.state()
            |> module.on_error()

          Instance.update(new_instance, handled_next)
        else
          new_instance
        end

      saved_instance = storage.save_instance(handled_instance)

      {:ok, saved_instance}
    else
      {:error, InstanceNotFoundError.exception(instance_id)}
    end
  end

  def value(instance_id, storage \\ default_storage()) do
    instance_id
    |> storage.get_instance()
    |> Instance.value()
  end

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
