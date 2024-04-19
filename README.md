# ArangodbTest

To use this test app:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Run `
  personal = ArangodbTest.Arangodb.get_personal!("256")
  params = %{"name" => "Stefano", "surname" => "Surname"}
  ArangodbTest.Arangodb.update_personal_hiring(personal, params)`



