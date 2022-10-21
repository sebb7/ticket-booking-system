## TicketBookingSystem

This project was created for learning purposes.

Functionalities:

- adding new event with given amount of tickets,
- booking the ticket
- listing events and tickets

## Running the system

Requirements for starting:

- postgres database running (credentials should be adjusted)

In order to start the project:

```elixir
 iex -S mix
```

Create an event with five numbered tickets:

```elixir
TicketBookingSystem.Events.create_with_tickets("test_event_name", 5)
```

List events with available tickets:

```elixir
TicketBookingSystem.Events.list_with_available_tickets()
```

Book a ticket with a given number:

```elixir
TicketBookingSystem.Tickets.book("test_event_name", 1, "test_email@example.com")
```

List bookings for given email:

```elixir
TicketBookingSystem.Tickets.list_for_email("test_email@example.com")
```
