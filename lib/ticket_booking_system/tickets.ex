defmodule TicketBookingSystem.Tickets do
  @moduledoc false

  import Ecto.Query

  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Repo
  alias Ecto.Multi

  @type ticket_booking_error ::
          :event_name_or_seat_number_not_found
          | :seat_already_taken
          | :event_name_seat_number_or_email_is_invalid

  @spec book(String.t(), integer, String.t()) :: :ok | {:error, term}
  def book(event_name, seat_number, booking_person_email) do
    multi =
      Multi.new()
      |> Multi.run(:ticket, fn repo, _ ->
        select_ticket_with_lock(repo, event_name, seat_number)
      end)
      |> Multi.run(:ticket_is_available, fn _repo, %{ticket: ticket} ->
        check_if_is_available(ticket)
      end)
      |> Multi.update(:book_seat, fn %{ticket: ticket} ->
        Ticket.book_seat_changeset(ticket, %{
          seat_number: seat_number,
          booking_person_email: booking_person_email,
          taken: true
        })
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        :ok

      {:error, :ticket, _, _} ->
        {:error, :event_name_or_seat_number_not_found}

      {:error, :ticket_is_available, _, _} ->
        {:error, :seat_already_taken}
    end
  end

  defp select_ticket_with_lock(repo, event_name, seat_number) do
    q =
      from(t in Ticket,
        join: e in assoc(t, :event),
        where: e.name == ^event_name,
        where: t.seat_number == ^seat_number,
        select: t,
        lock: "FOR UPDATE"
      )

    case repo.one(q) do
      nil ->
        {:error, :not_found}

      ticket ->
        {:ok, ticket}
    end
  end

  defp check_if_is_available(%Ticket{taken: false} = ticket) do
    {:ok, ticket}
  end

  defp check_if_is_available(_) do
    {:error, nil}
  end

  @spec list_for_email(String.t()) :: [Ticket.t()] | []
  def list_for_email(email) do
    q =
      from(t in Ticket,
        where: t.booking_person_email == ^email
      )

    Repo.all(q)
  end
end
