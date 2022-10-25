defmodule TicketBookingSystem.TicketsTest do
  use ExUnit.Case, async: true

  alias TicketBookingSystem.Events
  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Events.EventCreateParameters
  alias TicketBookingSystem.Tickets
  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Repo

  @test_email "test_email@example.com"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "book/3 for unnumbered tickets event" do
    setup do
      create_event_params = %EventCreateParameters{
        name: "test_event_name",
        tickets_amount: 3,
        tickets_type: :unnumbered
      }
      {:ok, %Event{id: event_id}} = Events.create(create_event_params)

      [event_name: create_event_params.name, event_id: event_id]
    end

    test "adds new ticket for given email", %{event_name: event_name, event_id: event_id} do
      assert Tickets.book(event_name, @test_email) == :ok

      assert [%Ticket{event_id: ^event_id, booking_person_email: @test_email, seat_number: nil}] =
        Repo.all(Ticket)
    end

    test "returns error when event not found" do
      assert Tickets.book("event_name", @test_email) == {:error, :event_not_found}
    end

    test "returns error when seat number is passed", %{event_name: event_name} do
      assert Tickets.book(event_name, @test_email, 1) ==
        {:error, :seat_number_passed_for_unnumbered_ticket_type_event}
    end

    test "returns error when there is no more tickets available", %{event_name: event_name} do
      Tickets.book(event_name, @test_email)
      Tickets.book(event_name, @test_email)
      Tickets.book(event_name, @test_email)
      assert Tickets.book(event_name, @test_email) ==
        {:error, :no_available_tickets}
    end
  end

  describe "book/3 for numbered tickets event" do
    setup do
      create_event_params = %EventCreateParameters{
        name: "test_event_name",
        tickets_amount: 3,
        tickets_type: :numbered
      }
      {:ok, %Event{id: event_id}} = Events.create(create_event_params)

      [event_name: create_event_params.name, event_id: event_id]
    end

    test "adds new ticket for given email and choosen seat", %{event_name: event_name, event_id: event_id} do
      assert Tickets.book(event_name, @test_email, 2) == :ok

      assert [%Ticket{event_id: ^event_id, booking_person_email: @test_email, seat_number: 2}] =
        Repo.all(Ticket)
    end

    test "returns error when event not found" do
      assert Tickets.book("event_name", @test_email, 2) == {:error, :event_not_found}
    end

    test "returns error when seat number does not exist", %{event_name: event_name} do
      assert Tickets.book(event_name, @test_email, 4) == {:error, :seat_number_does_not_exist}
    end

    test "returns error when seat number is not passed", %{event_name: event_name} do
      assert Tickets.book(event_name, @test_email) ==
        {:error, :no_seat_number_passed_for_numbered_ticket_type_event}
    end

    test "returns error when seat number is already taken", %{event_name: event_name} do
      assert Tickets.book(event_name, @test_email, 2) == :ok
      assert Tickets.book(event_name, @test_email, 2) == {:error, :seat_already_taken}
    end
  end

  describe "get_available_tickets_for_event/1" do
    test "returns available tickets for event with unnumbered tickets type" do
      event_name = "test_event_unnumbered"

      create_event_unnumbered_tickets_params = %EventCreateParameters{
        name: event_name,
        tickets_amount: 3,
        tickets_type: :unnumbered
      }

      Events.create(create_event_unnumbered_tickets_params)

      Tickets.book(event_name, @test_email)

      assert Tickets.get_available_tickets_for_event(event_name) ==
               {:ok, :available_tickets_amount, 2}
    end

    test "returns available tickets for event with numbered tickets type" do
      event_name = "test_event_numbered"

      create_event_numbered_tickets_params = %EventCreateParameters{
        name: event_name,
        tickets_amount: 3,
        tickets_type: :numbered
      }

      Events.create(create_event_numbered_tickets_params)

      Tickets.book(event_name, @test_email, 2)

      assert Tickets.get_available_tickets_for_event(event_name) ==
               {:ok, :available_tickets_list, [1, 3]}
    end

    test "returns error for not found ticket" do
      assert Tickets.get_available_tickets_for_event("test_event_name") ==
               {:error, :event_not_found}
    end
  end

  test "list_for_email/1 returns event for given booking person email" do
    email = @test_email

    create_event_unnumbered_tickets_params = %EventCreateParameters{
      name: "test_event_unnumbered",
      tickets_amount: 3,
      tickets_type: :unnumbered
    }

    create_event_numbered_tickets_params = %EventCreateParameters{
      name: "test_event_numbered",
      tickets_amount: 3,
      tickets_type: :numbered
    }

    Events.create(create_event_unnumbered_tickets_params)
    Events.create(create_event_numbered_tickets_params)

    Tickets.book("test_event_unnumbered", email)
    Tickets.book("test_event_numbered", email, 1)

    assert [
             %Ticket{
               seat_number: nil,
               booking_person_email: ^email
             },
             %Ticket{
               seat_number: 1,
               booking_person_email: ^email
             }
           ] = Tickets.list_for_email(email)
  end
end
