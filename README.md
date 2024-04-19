# ArangodbTest

To use this test app:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Run `personal = ArangodbTest.Arangodb.get_personal!("256")`
  * Run `params = %{"name" => "Stefano", "surname" => "Surname"}`
  * Run `ArangodbTest.Arangodb.update_personal_hiring(personal, params)`



