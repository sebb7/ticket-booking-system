import Config

config :ticket_booking_system,
  ecto_repos: [TicketBookingSystem.Repo]

import_config "#{Mix.env()}.exs"
