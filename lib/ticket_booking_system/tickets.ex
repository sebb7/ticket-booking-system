defmodule TicketBookingSystem.Tickets do
  @moduledoc false

  import Ecto.Query

  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Repo
  alias Ecto.Multi

  @type ticket_booking_error ::
          :event_not_found
          | :no_seat_number_passed_for_numbered_ticket_type_event
          | :seat_number_passed_for_unnumbered_ticket_type_event
          | :no_available_tickets
          | :seat_number_does_not_exist
          | :seat_already_taken

  @type available_tickets_list :: [integer]
  @type available_tickets_amount :: integer

  @type available_tickets ::
          {:ok, :avilable_tickets_list, available_tickets_list}
          | {:ok, :available_tickets_amount, available_tickets_amount}

  @spec book(String.t(), integer, String.t() | nil) :: :ok | {:error, ticket_booking_error}
  def book(event_name, booking_person_email, seat_number \\ nil)

  def book(event_name, booking_person_email, seat_number) when is_nil(seat_number) do
    multi =
      Multi.new()
      |> Multi.run(:event, fn repo, _ ->
        select_event_with_lock(repo, event_name)
      end)
      |> Multi.run(:unnumbered_tickets_type, fn _repo, %{event: event} ->
        check_if_unnumbered_tickets_type(event)
      end)
      |> Multi.run(:available_tickets, fn _repo, %{event: event} ->
        check_if_there_are_free_tickets(event)
      end)
      |> Multi.insert(:book_ticket, fn %{event: event} ->
        Ticket.unnumbered_ticket_changeset(%Ticket{}, %{
          event_id: event.id,
          booking_person_email: booking_person_email
        })
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        :ok

      {:error, :event, :not_found, _} ->
        {:error, :event_not_found}

      {:error, :unnumbered_tickets_type, nil, _} ->
        {:error, :no_seat_number_passed_for_numbered_ticket_type_event}

      {:error, :available_tickets, nil, _} ->
        {:error, :no_available_tickets}
    end
  end

  def book(event_name, booking_person_email, seat_number) do
    q = from(e in Event, where: e.name == ^event_name)

    with {:get_event, %Event{id: event_id, tickets_amount: tickets_amount} = event} <- {:get_event, Repo.one(q)},
         {:numbered_tickets_event?, true} <- {:numbered_tickets_event?, numbered_tickets_event?(event)},
         {:seat_number_exists?, true} <-
           {:seat_number_exists?, seat_number_exists?(seat_number, tickets_amount)},
         {:ok, _} <- insert_numbered_ticket(event_id, booking_person_email, seat_number) do
      :ok
    else
      {:get_event, nil} ->
        {:error, :event_not_found}

      {:numbered_tickets_event?, false} ->
        {:error, :seat_number_passed_for_unnumbered_ticket_type_event}

      {:seat_number_exists?, false} ->
        {:error, :seat_number_does_not_exist}

      {:error, %Ecto.Changeset{errors: [event_id: {_, [{:constraint, :unique}, _]}]}} ->
        {:error, :seat_already_taken}
    end
  end

  defp select_event_with_lock(repo, event_name) do
    q = from(e in Event, where: e.name == ^event_name, lock: "FOR UPDATE")

    case repo.one(q) do
      nil ->
        {:error, :not_found}

      event ->
        {:ok, event}
    end
  end

  defp check_if_unnumbered_tickets_type(%Event{tickets_type: :unnumbered}) do
    {:ok, nil}
  end

  defp check_if_unnumbered_tickets_type(_) do
    {:error, nil}
  end

  defp check_if_there_are_free_tickets(%Event{id: id, tickets_amount: tickets_amount}) do
    number_of_existing_tickets_for_event = count_existing_tickets_for_event(id)

    if number_of_existing_tickets_for_event < tickets_amount do
      {:ok, nil}
    else
      {:error, nil}
    end
  end

  defp insert_numbered_ticket(event_id, booking_person_email, seat_number) do
    %Ticket{}
    |> Ticket.numbered_ticket_changeset(%{
      event_id: event_id,
      booking_person_email: booking_person_email,
      seat_number: seat_number
    })
    |> Repo.insert()
  end

  defp seat_number_exists?(seat_number, tickets_amount) do
    seat_number in 1..tickets_amount
  end


  defp numbered_tickets_event?(%Event{tickets_type: :numbered}) do
    true
  end

  defp numbered_tickets_event?(_) do
    false
  end

  defp count_existing_tickets_for_event(event_id) do
    q = from(t in Ticket, where: t.event_id == ^event_id, select: count("*"))
    Repo.one(q)
  end

  @spec list_for_email(String.t()) :: [Ticket.t()] | []
  def list_for_email(email) do
    q =
      from(t in Ticket,
        where: t.booking_person_email == ^email
      )

    Repo.all(q)
  end

  @spec get_available_tickets_for_event(String.t()) ::
          available_tickets | {:error, :event_not_found}
  def get_available_tickets_for_event(event_name) do
    q = from(e in Event, where: e.name == ^event_name)

    case Repo.one(q) do
      %Event{id: id, tickets_amount: tickets_amount, tickets_type: :unnumbered} ->
        available_amount = tickets_amount - count_existing_tickets_for_event(id)
        {:ok, :available_tickets_amount, available_amount}

      %Event{id: id, tickets_amount: tickets_amount, tickets_type: :numbered} ->
        q_taken_seats = from(t in Ticket, where: t.event_id == ^id, select: t.seat_number)

        taken_seat_numbers = Repo.all(q_taken_seats)

        all_seats = Enum.to_list(1..tickets_amount)

        available_tickets = all_seats -- taken_seat_numbers

        {:ok, :available_tickets_list, available_tickets}

      nil ->
        {:error, :event_not_found}
    end
  end
end
