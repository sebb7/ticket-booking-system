defmodule TicketBookingSystemTest do
  use ExUnit.Case
  doctest TicketBookingSystem

  test "greets the world" do
    assert TicketBookingSystem.hello() == :world
  end
end
