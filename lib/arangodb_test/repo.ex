defmodule ArangodbTest.Repo do
  use Ecto.Repo,
    otp_app: :arangodb_test,
    # adapter: Ecto.Adapters.Postgres
    adapter: ArangoXEcto.Adapter
end
