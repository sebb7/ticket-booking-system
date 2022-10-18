defmodule TicketBookingSystem.Repo do
  use Ecto.Repo,
    otp_app: :ticket_booking_system,
    adapter: Ecto.Adapters.Postgres
end
