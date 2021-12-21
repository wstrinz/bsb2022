defmodule Bsb2022.Repo do
  use Ecto.Repo,
    otp_app: :bsb2022,
    adapter: Ecto.Adapters.Postgres
end
