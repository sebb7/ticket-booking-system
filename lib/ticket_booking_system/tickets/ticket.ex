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
    field(:taken, :boolean)
    field(:booking_person_email, :string)

    belongs_to(:event, Event, type: :binary_id)

    timestamps()
  end

  @spec init_changeset(t, map) :: Ecto.Changeset.t()
  def init_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:seat_number])
    |> validate_required([:seat_number])
  end

  @spec book_seat_changeset(t, map) :: Ecto.Changeset.t()
  def book_seat_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:seat_number, :taken, :booking_person_email])
    |> validate_required([:seat_number, :taken, :booking_person_email])
  end

  @spec new(map) :: {:ok, t} | {:error, Ecto.Changeset.t()}
  def new(attrs) do
    %Ticket{}
    |> init_changeset(attrs)
    |> apply_action(:new)
  end
end
