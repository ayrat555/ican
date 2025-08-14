defmodule ICANTest do
  use ExUnit.Case, async: true

  @samples __DIR__
           |> Path.join("samples.json")
           |> File.read!()
           |> Jason.decode!()

  # -------------------- Valid / Invalid --------------------

  Enum.each(@samples["valid"], fn %{"ican" => ican} ->
    test "valid: OK - Check ICAN: #{ican}" do
      assert ICAN.is_valid(unquote(ican))
    end
  end)

  Enum.each(@samples["invalid"], fn %{"ican" => ican} ->
    test "invalid: NOK - Check ICAN: #{ican}" do
      refute ICAN.is_valid(unquote(ican))
    end
  end)

  # -------------------- Crypto variants --------------------

  Enum.each(@samples["validCrypto"], fn %{"ican" => ican} ->
    test "validCrypto: OK - Check Crypto ICAN: #{ican}" do
      assert ICAN.is_valid(unquote(ican), true)
    end
  end)

  Enum.each(@samples["validMainnetCrypto"], fn %{"ican" => ican} ->
    test "validMainnetCrypto: OK - Check Crypto Mainnet ICAN: #{ican}" do
      assert ICAN.is_valid(unquote(ican), "main")
    end
  end)

  Enum.each(@samples["validTestnetCrypto"], fn %{"ican" => ican} ->
    test "validTestnetCrypto: OK - Check Crypto Testnet ICAN: #{ican}" do
      assert ICAN.is_valid(unquote(ican), "testnet")
    end
  end)

  Enum.each(@samples["invalidCrypto"], fn %{"ican" => ican} ->
    test "invalidCrypto: NOK - Check Crypto ICAN: #{ican}" do
      refute ICAN.is_valid(unquote(ican), true)
    end
  end)

  # -------------------- Formatting helpers --------------------

  Enum.each(@samples["print"], fn %{"ican" => ican, "pair" => pair} ->
    test "print: OK - Print format: #{ican}" do
      assert ICAN.print_format(unquote(ican)) == unquote(pair)
    end
  end)

  Enum.each(@samples["electronic"], fn %{"ican" => ican, "pair" => pair} ->
    test "electronic: OK - Electronic format: #{ican}" do
      assert ICAN.electronic_format(unquote(ican)) == unquote(pair)
    end
  end)

  Enum.each(@samples["short"], fn %{"ican" => ican, "pair" => pair} ->
    test "short: OK - Short format: #{ican}" do
      assert ICAN.short_format(unquote(ican)) == unquote(pair)
    end
  end)
end
