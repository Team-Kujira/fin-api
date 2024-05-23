defmodule FinApi.Invalidator do
  alias Phoenix.PubSub
  use GenServer
  require Logger

  @impl true
  def init(opts) do
    PubSub.subscribe(FinApi.PubSub, "tendermint/event/Tx")

    {:ok, opts}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def handle_info(%{TxResult: %{result: %{events: events}}}, state) do
    Enum.flat_map(events, &scan_event/1)
    |> Enum.uniq()
    |> Enum.map(&invalidate/1)

    {:noreply, state}
  end

  defp scan_event(%{attributes: attributes}) do
    scan_attributes(attributes)
  end

  defp scan_attributes(attributes, collection \\ [])

  defp scan_attributes(
         [
           %{
             key: "_contract_address",
             value: value
           }
           | rest
         ],
         collection
       ) do
    scan_attributes(rest, [{Kujira.Fin, :load_pair, [value]} | collection])
  end

  defp scan_attributes([_ | rest], collection), do: scan_attributes(rest, collection)
  defp scan_attributes([], collection), do: collection

  defp invalidate({module, function, args}) do
    Logger.debug("#{__MODULE__} invalidating #{module}.#{function} #{Enum.join(args, ",")}")
    Memoize.invalidate(module, function, args)
  end
end
