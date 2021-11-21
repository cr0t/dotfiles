defmodule GenServerTemplate do
  @moduledoc """
  A GenServer template for a "singleton" process. There are a few examples shown, clean unused.
  """

  # restart only if terminates abnormally
  use GenServer, restart: :transient

  ###
  # Public API
  ###

  def hloo(value),
    do: GenServer.call(__MODULE__, {:hloo, value})

  def gloo(value),
    do: GenServer.cast(__MODULE__, {:gloo, value})

  ###
  # Initialization
  ###

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Process.send_after(self(), {:update, :example_value}, 5_000)

    state = %{
      foo: nil,
      bar: nil,
      baz: nil
    }

    {:ok, state}
  end

  ###
  # GenServer's Kitchen
  ###

  @impl true
  def handle_call({:hloo, value}, _from, state) do
    resp = "value: #{inspect(value)}"
    state = %{state | foo: value}

    {:reply, resp, state}
  end

  @impl true
  def handle_cast({:gloo, value}, state) do
    state = %{state | bar: value}

    {:noreply, state}
  end

  @impl true
  def handle_info({:update, value}, state) do
    state = %{state | baz: value}

    {:noreply, state}
  end
end
