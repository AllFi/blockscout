defmodule Explorer.Repo.Eip7702.Migrations.CreateEip7702Authorizations do
  use Ecto.Migration

  def change do
    create table(:eip7702_authorizations, primary_key: false) do
      add(:transaction_hash, references(:transactions, column: :hash, on_delete: :delete_all, type: :bytea), null: false)

      add(:index, :integer, null: false)
      add(:chain_id, :integer, null: false)
      add(:address, :bytea, null: false)
      add(:nonce, :integer, null: false)
      add(:y_parity, :integer, null: false)
      add(:r, :numeric, precision: 100, null: false)
      add(:s, :numeric, precision: 100, null: false)

      timestamps(null: false, type: :utc_datetime_usec)
    end
  end
end
