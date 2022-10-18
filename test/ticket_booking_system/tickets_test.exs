defmodule TicketBookingSystem.TicketsTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  alias TicketBookingSystem.Events
  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Tickets
  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "book/3" do
    test "changes the ticket state to `taken: true` and sets the booking person email" do
      {:ok, %Event{id: event_id}} = Events.create_with_tickets("test_event", 2)

      assert Tickets.book("test_event", 1, "test@example.com") == :ok

      assert [
               %Ticket{
                 seat_number: 1,
                 taken: true,
                 booking_person_email: "test@example.com",
                 event_id: ^event_id
               },
               %Ticket{
                 seat_number: 2,
                 taken: false,
                 booking_person_email: nil,
                 event_id: ^event_id
               }
      ] = Repo.all(from t in Ticket, order_by: :seat_number)
    end

    test "returns error when non existing event is used" do
      assert Tickets.book("test_event", 1, "test@example.com") ==
               {:error, :event_name_or_seat_number_not_found}
    end

    test "returns error when non existing seat number is used" do
      Events.create_with_tickets("test_event", 2)

      assert Tickets.book("test_event", 3, "test@example.com") ==
               {:error, :event_name_or_seat_number_not_found}
    end

    test "returns error when non existing seat is already taken" do
      Events.create_with_tickets("test_event", 2)
      Tickets.book("test_event", 2, "test@example.com")
      assert Tickets.book("test_event", 2, "test@example.com") == {:error, :seat_already_taken}
    end
  end

  test "list_for_email/1 returns event for given booking person email" do
    email = "test@example.com"

    Events.create_with_tickets("test_event_1", 2)
    Tickets.book("test_event_1", 1, email)
    Events.create_with_tickets("test_event_2", 2)
    Tickets.book("test_event_2", 1, email)

    assert [_, _] = Tickets.list_for_email(email)
  end
end
