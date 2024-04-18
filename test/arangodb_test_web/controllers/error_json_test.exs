defmodule ArangodbTestWeb.ErrorJSONTest do
  use ArangodbTestWeb.ConnCase, async: true

  test "renders 404" do
    assert ArangodbTestWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ArangodbTestWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
