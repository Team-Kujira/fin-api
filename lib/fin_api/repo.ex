defmodule FinApi.Repo do
  use Ecto.Repo,
    otp_app: :fin_api,
    adapter: Ecto.Adapters.Postgres
end
