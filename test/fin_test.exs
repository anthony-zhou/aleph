defmodule FinTest do
  use ExUnit.Case, async: true
  doctest Fin

  test "send message" do
    assert Fin.send_message(:moebi@localhost, "hi") == :ok
  end
end
