## TicketBookingSystem

This project allows for a simple management of event bookings.

Functionalities:

- creation of a new event which has given number of tickets available,
- specifying if an event has unnumbered or numbered tickets type,
- listing available ticket seat numbers for the event with numbered tickets,
- viewing available tickets amount for the event with unnumbered tickets,
- booking the ticket using the email,
- listing tickets booked with given email

## Running the system

Requirements for starting:

- postgres database running (compose file can be used)

In order to start the project:

```shell
mix deps.get
mix ecto.create
mix ecto.migrate

iex -S mix
```

Create an event:

```elixir
# with unnumbered tickets
attrs = %{name: "test_event_unnumbered", tickets_amount: 4, tickets_type: :unnumbered}
{:ok, create_params} = TicketBookingSystem.Events.EventCreateParameters.new(attrs)
TicketBookingSystem.Events.create(create_params)

# with numbered tickets
attrs = %{name: "test_event_numbered", tickets_amount: 4, tickets_type: :numbered}
{:ok, create_params} = TicketBookingSystem.Events.EventCreateParameters.new(attrs)
TicketBookingSystem.Events.create(create_params)
```

Get available tickets for the given event:

```elixir
 TicketBookingSystem.Tickets.get_available_tickets_for_event("test_event_numbered")
```

Book a ticket with a given number:

```elixir
# with unnumbered tickets
TicketBookingSystem.Tickets.book("test_event_unnumbered", "test_email@example.com")
# with numbered tickets
TicketBookingSystem.Tickets.book("test_event_numbered", "test_email@example.com", 1)
```

List bookings for given email:

```elixir
TicketBookingSystem.Tickets.list_for_email("test_email@example.com")
```
