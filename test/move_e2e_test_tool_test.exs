defmodule MoveE2ETestToolTest do
  use ExUnit.Case
  doctest MoveE2ETestTool

  test "greets the world" do
    assert MoveE2ETestTool.hello() == :world
  end
end
