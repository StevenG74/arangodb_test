defmodule ArangodbTest.Arangodb do
  import Ecto.Query
  alias ArangodbTest.Model.Personal

  @repo ArangodbTest.Repo

  def get_personal_2!(id) do
    @repo.get!(Personal, id)
  end

  def get_personal!(id) do
    query = from e in "employee",
      where: e._key == ^id,
      select: e
    @repo.one(query)
    |> ArangoXEcto.load(Personal)
  end

  def update_personal_hiring(%Personal{} = personal, params) do
    personal
    |> Personal.changeset_hiring(params)
    |> @repo.update()
  end


end
