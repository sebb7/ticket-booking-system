defmodule TicketBookingSystem.Repo.Migrations.IntroduceUnnumberedAndNumberedTickets do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :tickets_amount, :integer
      add :tickets_type, :integer
    end

    alter table(:tickets) do
      remove :taken
    end

    create unique_index(:tickets, [:event_id, :seat_number], name: :unique_event_id_and_seat_number)
  end
end
