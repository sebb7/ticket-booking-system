import Config

config :ticket_booking_system, TicketBookingSystem.Repo,
  database: "ticket_booking_system_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
