defmodule TicketBookingSystem.EventsTest do
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

  describe "create_with_tickets/2" do
    test "given valid params saves an event with tickets in db" do
      assert Enum.empty?(Repo.all(Event))

      assert {:ok, %Event{id: event_id}} = Events.create_with_tickets("test_event", 2)

      assert [%Event{id: ^event_id}] = Repo.all(Event)

      assert [
               %Ticket{
                 seat_number: 1,
                 taken: false,
                 booking_person_email: nil,
                 event_id: ^event_id
               },
               %Ticket{
                 seat_number: 2,
                 taken: false,
                 booking_person_email: nil,
                 event_id: ^event_id
               }
             ] = Repo.all(from(t in Ticket, order_by: :seat_number))
    end

    test "given too high number of tickets returns error" do
      assert {:error, :invalid_number_of_tickets} = Events.create_with_tickets("test_event", 0)

      assert Enum.empty?(Repo.all(Event))
    end

    test "given existing event name returns error" do
      assert {:ok, _} = Events.create_with_tickets("test_event", 2)
      assert {:error, %Ecto.Changeset{}} = Events.create_with_tickets("test_event", 2)
    end
  end

  test "list_with_tickets/0 returns all events with tickets" do
    {:ok, %Event{}} = Events.create_with_tickets("test_event_1", 2)
    {:ok, %Event{}} = Events.create_with_tickets("test_event_2", 2)

    Tickets.book("test_event_1", 2, "test@example.com")
    Tickets.book("test_event_2", 2, "test@example.com")

    assert [
             %Event{
               tickets: [
                 %Ticket{},
                 %Ticket{}
               ]
             },
             %Event{
               tickets: [
                 %Ticket{},
                 %Ticket{}
               ]
             }
           ] = Events.list_with_tickets()
  end

  test "list_with_available_tickets/1 given event name returns events with avialble tickets" do
    {:ok, %Event{}} = Events.create_with_tickets("test_event_1", 1)
    {:ok, %Event{}} = Events.create_with_tickets("test_event_2", 2)

    Tickets.book("test_event_2", 2, "test@example.com")

    assert [
             %Event{
               tickets: [
                 %Ticket{}
               ]
             },
             %Event{
               tickets: [
                 %Ticket{}
               ]
             }
           ] = Events.list_with_available_tickets()
  end
end
