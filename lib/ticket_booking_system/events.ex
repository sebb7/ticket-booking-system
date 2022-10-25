defmodule TicketBookingSystem.Events do
  @moduledoc false

  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Events.EventCreateParameters
  alias TicketBookingSystem.Repo

  @max_amount_of_tickets 10

  @spec create(EventCreateParameters.t()) ::
          {:ok, Event.t()} | {:error, :invalid_amount_of_tickets | :event_name_already_taken}
  def create(create_parameteres) do
    with :ok <- validate_tickets_amount(create_parameteres.tickets_amount),
         {:ok, event} <- insert_event(create_parameteres) do
      {:ok, event}
    else
      {:error, :invalid_amount_of_tickets} = error ->
        error

      {:error, %Ecto.Changeset{errors: [name: {_, [{:constraint, :unique}, _]}]}} ->
        {:error, :event_name_already_taken}
    end
  end

  defp validate_tickets_amount(a) when a in 1..@max_amount_of_tickets do
    :ok
  end

  defp validate_tickets_amount(_a) do
    {:error, :invalid_amount_of_tickets}
  end

  defp insert_event(create_parameteres) do
    attrs = Map.from_struct(create_parameteres)

    %Event{}
    |> Event.changeset(%{
      name: attrs.name,
      tickets_amount: attrs.tickets_amount,
      tickets_type: attrs.tickets_type
    })
    |> Repo.insert()
  end

  @spec list() :: [Event.t()]
  def list do
    Repo.all(Event)
  end
end
