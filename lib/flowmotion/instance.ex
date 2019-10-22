defmodule Flowmotion.Instance do
  use TypedStruct

  alias __MODULE__
  alias Flowmotion.{Next, Workflow}

  @type id :: any

  typedstruct opaque: true, enforce: true do
    field(:id, id)
    field(:workflow_module, module)
    field(:status, Workflow.status())
    field(:state, Workflow.state())
  end

  @spec id(t) :: id
  def id(instance), do: instance.id

  @spec workflow_module(t) :: module
  def workflow_module(instance), do: instance.workflow_module

  @spec state(t) :: Workflow.state()
  def state(instance), do: instance.state

  @spec errored?(t) :: boolean
  def errored?(instance), do: instance.status == :errored

  @spec new(id, module, Next.t()) :: t
  def new(id, workflow_module, next) do
    %Instance{
      id: id,
      workflow_module: workflow_module,
      status: Next.status(next),
      state: Next.state(next)
    }
  end

  @spec update(t, Next.t()) :: t
  def update(instance, next) do
    status = Next.status(next)
    state = Next.state(next)

    %{instance | status: status, state: state}
  end

  @spec value(t) :: any
  def value(instance) do
    instance.workflow_module.value(instance.state)
  end

  # @spec call_workflow(t, any) :: Next.t
  # def call_workflow(instance, message) do
  #   instance.module.setp(instance.state)
  # end
end
