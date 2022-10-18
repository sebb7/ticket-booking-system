defmodule TicketBookingSystem.Events do
  @moduledoc false

  import Ecto.Query

  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Repo

  @max_number_of_tickets 10

  @spec create_with_tickets(String.t(), non_neg_integer) ::
          {:ok, Event.t()}
          | {:error, Ecto.Changeset.t() | :invalid_number_of_tickets | :event_name_already_taken}
  def create_with_tickets(event_name, tickets_number) do
    with :ok <- validate_tickets_number(tickets_number) do
      tickets = create_event_tickets(tickets_number)

      %Event{}
      |> Event.changeset(%{name: event_name, tickets: tickets})
      |> Repo.insert()
    else
      {:error, :invalid_number_of_tickets} = error ->
        error

      {:error, %Ecto.Changeset{errors: [name: {_, [{:constraint, :unique}, _]}]}} ->
        {:error, :event_name_already_taken}
    end
  end

  defp validate_tickets_number(number) when number in 1..@max_number_of_tickets do
    :ok
  end

  defp validate_tickets_number(_number) do
    {:error, :invalid_number_of_tickets}
  end

  defp create_event_tickets(number_of_tickets) do
    Enum.map(1..number_of_tickets, &create_ticket/1)
  end

  defp create_ticket(seat_number) do
    {:ok, ticket} = Ticket.new(%{seat_number: seat_number})
    ticket
  end

  @spec list_with_tickets() :: [Event.t()]
  def list_with_tickets do
    q =
      from(e in Event,
        join: t in assoc(e, :tickets),
        preload: [tickets: t]
      )

    Repo.all(q)
  end

  @spec list_with_available_tickets() :: [Event.t()] | []
  def list_with_available_tickets do
    q =
      from(e in Event,
        join: t in assoc(e, :tickets),
        where: t.taken == ^false,
        preload: [tickets: t]
      )

    Repo.all(q)
  end
end
