defmodule SymphonyElixir.MixProjectTest do
  use ExUnit.Case, async: true

  test "dialyzer stores core PLTs under the project build directory" do
    dialyzer_config = SymphonyElixir.MixProject.project() |> Keyword.fetch!(:dialyzer)

    assert Keyword.fetch!(dialyzer_config, :plt_core_path) == "_build/dialyxir_core"
  end
end
