defmodule TicketBookingSystem.Events.EventCreateParameters do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias TicketBookingSystem.Events.EventCreateParameters

  @type t :: %EventCreateParameters{}

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:tickets_amount, :integer)
    field(:tickets_type, Ecto.Enum, values: [:numbered, :unnumbered])
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(event_paramateres, attrs) do
    event_paramateres
    |> cast(attrs, [:name, :tickets_amount, :tickets_type])
    |> validate_required([:name, :tickets_amount, :tickets_type])
  end

  @spec new(map) :: {:ok, t}
  def new(attrs) do
    %EventCreateParameters{}
    |> changeset(attrs)
    |> apply_action(:new)
  end
end
