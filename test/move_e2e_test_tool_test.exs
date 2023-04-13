defmodule MoveE2eTestToolTest do
  use ExUnit.Case
  doctest MoveE2eTestTool

  test "greets the world" do
    assert MoveE2eTestTool.hello() == :world
  end
end
