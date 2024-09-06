defmodule Explorer.Chain.Import.Runner.Eip7702.Authorizations do
  @moduledoc """
  Fix me
  """

  require Ecto.Query

  alias Ecto.{Changeset, Multi, Repo}
  alias Explorer.Chain.{Import, Eip7702.Authorization}
  alias Explorer.Prometheus.Instrumenter

  @behaviour Import.Runner

  # milliseconds
  @timeout 60_000

  @type imported :: [Authorization.t()]

  @impl Import.Runner
  def ecto_schema_module, do: Authorization

  @impl Import.Runner
  def option_key, do: :eip7702_authorizations

  @impl Import.Runner
  def imported_table_row do
    %{
      value_type: "[#{ecto_schema_module()}.t()]",
      value_description: "List of `t:#{ecto_schema_module()}.t/0`s"
    }
  end

  @impl Import.Runner
  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    Multi.run(multi, :eip7702_authorizations, fn repo, _ ->
      Instrumenter.block_import_stage_runner(
        fn -> insert(repo, changes_list, insert_options) end,
        :block_referencing,
        :logs,
        :logs
      )
    end)
  end

  @impl Import.Runner
  def timeout, do: @timeout

  @spec insert(Repo.t(), [map()], %{
          optional(:on_conflict) => Import.Runner.on_conflict(),
          required(:timeout) => timeout,
          required(:timestamps) => Import.timestamps()
        }) ::
          {:ok, [Authorization.t()]}
          | {:error, [Changeset.t()]}
  defp insert(repo, changes_list, %{timeout: timeout, timestamps: timestamps} = options) when is_list(changes_list) do
    {:ok, _} =
      Import.insert_changes_list(
        repo,
        changes_list,
        for: Authorization,
        returning: true,
        timeout: timeout,
        timestamps: timestamps
      )
  end
end
