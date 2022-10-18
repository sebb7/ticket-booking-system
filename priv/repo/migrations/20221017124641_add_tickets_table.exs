defmodule TicketBookingSystem.Repo.Migrations.AddTicketsTable do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :seat_number, :integer
      add :taken, :boolean, default: false
      add :booking_person_email, :string

      add :event_id, references(:events, type: :uuid)

      timestamps()
    end

    create unique_index(:tickets, [:event_id, :seat_number], name: :tickets_event_id_seat_number_index)
  end
end
