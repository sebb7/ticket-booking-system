defmodule TicketBookingSystem.Events.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias TicketBookingSystem.Tickets.Ticket

  @type t :: %Event{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field(:name, :string)

    has_many(:tickets, Ticket)

    timestamps()
  end

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(event, attrs) do
    tickets = Map.get(attrs, :tickets)

    event
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> put_assoc(:tickets, tickets)
  end
end
