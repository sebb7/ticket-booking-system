defmodule TicketBookingSystem.Events.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias TicketBookingSystem.Tickets.Ticket
  alias TicketBookingSystem.Events.Event

  @type t :: %Event{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field(:name, :string)
    field(:tickets_amount, :integer)
    field(:tickets_type, Ecto.Enum, values: [numbered: 1, unnumbered: 0])

    has_many(:tickets, Ticket)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :tickets_type, :tickets_amount])
    |> validate_required([:name, :tickets_type, :tickets_amount])
    |> unique_constraint(:name)
  end
end
