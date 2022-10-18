defmodule TicketBookingSystem.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string

      timestamps()
    end

    create index(:events, [:name], unique: true)
  end
end
