defmodule Flowmotion.Storage do
  alias Flowmotion.Instance

  @callback new_instance(module, any) :: Instance.t()
  @callback get_instance(Instance.id()) :: Instance.t() | nil
  @callback save_instance(Instance.t()) :: Instance.t()
end
