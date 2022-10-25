defmodule TicketBookingSystem.Tickets.Ticket do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias TicketBookingSystem.Events.Event
  alias TicketBookingSystem.Tickets.Ticket

  @type t :: %Ticket{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "tickets" do
    field(:seat_number, :integer)
    field(:booking_person_email, :string)

    belongs_to(:event, Event, type: :binary_id)

    timestamps()
  end

  @spec numbered_ticket_changeset(t, map) :: Ecto.Changeset.t()
  def numbered_ticket_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:event_id, :seat_number, :booking_person_email])
    |> validate_required([:event_id, :seat_number, :booking_person_email])
    |> unique_constraint([:event_id, :seat_number])
  end

  @spec unnumbered_ticket_changeset(t, map) :: Ecto.Changeset.t()
  def unnumbered_ticket_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:event_id, :booking_person_email])
    |> validate_required([:event_id, :booking_person_email])
  end
end
