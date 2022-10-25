defmodule TicketBookingSystem.EventsTest do
  use ExUnit.Case, async: true

  alias TicketBookingSystem.Events
  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Events.EventCreateParameters
  alias TicketBookingSystem.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    create_event_params = %EventCreateParameters{
      name: "test_event_name",
      tickets_amount: 3,
      tickets_type: :unnumbered
    }

    [create_event_params: create_event_params]
  end

  describe "create/2" do
    test "given valid params saves an event in db", %{create_event_params: params} do
      assert Enum.empty?(Repo.all(Event))

      assert {:ok, %Event{id: event_id}} = Events.create(params)

      assert [%Event{id: ^event_id}] = Repo.all(Event)
    end

    test "given too high number of tickets returns error", %{create_event_params: params} do
      wrong_tickets_number_params = %{params | tickets_amount: 20}
      assert Events.create(wrong_tickets_number_params) == {:error, :invalid_amount_of_tickets}

      assert Enum.empty?(Repo.all(Event))
    end

    test "given existing event name returns error", %{create_event_params: params} do
      assert {:ok, %Event{}} = Events.create(params)
      assert Events.create(params) == {:error, :event_name_already_taken}
    end
  end

  test "list/0 returns all eventss", %{create_event_params: params} do
    different_name_params = %{params | name: "test_event_name_2"}

    Events.create(params)
    Events.create(different_name_params)

    assert length(Events.list()) == 2
  end
end
