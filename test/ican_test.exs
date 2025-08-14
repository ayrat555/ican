defmodule IcanTest do
  use ExUnit.Case
  doctest Ican

  test "greets the world" do
    assert Ican.hello() == :world
  end
end
