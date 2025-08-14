defmodule ICAN.Specification do
  @moduledoc false
  @enforce_keys [:country_code, :length, :structure, :crypto, :example, :regex]
  defstruct [:country_code, :length, :structure, :crypto, :example, :regex]

  @type t :: %__MODULE__{
          country_code: String.t(),
          length: pos_integer(),
          structure: String.t(),
          crypto: ICAN.crypto(),
          example: String.t(),
          regex: Regex.t()
        }

  @format_map %{
    "A" => "0-9A-Za-z",
    "B" => "0-9A-Z",
    "C" => "A-Za-z",
    "H" => "0-9A-Fa-f",
    "F" => "0-9",
    "L" => "a-z",
    "U" => "A-Z",
    "W" => "0-9a-z"
  }

  @doc false
  def new(country_code, length, structure, crypto, example) do
    with :ok <- validate_country_code(country_code),
         :ok <- validate_structure(structure) do
      {:ok,
       %__MODULE__{
         country_code: country_code,
         length: length,
         structure: structure,
         crypto: normalize_crypto(crypto),
         example: example,
         regex: parse_structure(structure)
       }}
    end
  end

  def validate_country_code(code) when is_binary(code) and byte_size(code) == 2 do
    if code =~ ~r/^[A-Z]{2}$/ do
      :ok
    else
      {:error, "invalid country code"}
    end
  end

  def validate_country_code(_), do: {:error, "invalid country code"}

  defp validate_structure(structure) when is_binary(structure) do
    case Regex.run(~r/^([ABCHFLUW]\d{2})+$/, structure) do
      nil -> {:error, "invalid structure format"}
      _ -> :ok
    end
  end

  defp normalize_crypto(crypto) do
    case crypto do
      atom when atom in [:main, :test, :enter, false] -> atom
      "main" -> :main
      "mainnet" -> :main
      "test" -> :test
      "testnet" -> :test
      "enter" -> :enter
      "enterprise" -> :enter
      true -> :any_crypto
      _ -> false
    end
  end

  defp parse_structure(structure) do
    pattern =
      structure
      |> String.to_charlist()
      |> Enum.chunk_every(3)
      |> Enum.map_join(fn [pat | count_chars] ->
        cls = Map.fetch!(@format_map, <<pat>>)
        count = List.to_integer(count_chars)
        "([#{cls}]{#{count}})"
      end)

    Regex.compile!("^#{pattern}$")
  end

  def is_valid(%__MODULE__{} = spec, ican, only_crypto \\ false) when is_binary(ican) do
    ican = ICAN.electronic_format(ican)

    with true <- spec.length == String.length(ican),
         true <- spec.country_code == String.slice(ican, 0, 2),
         true <- is_matching_crypto(spec, only_crypto),
         true <- Regex.match?(spec.regex, String.slice(ican, 4..-1//1)),
         1 <- ICAN.iso7064_mod97(ICAN.iso13616_prepare(ican)) do
      true
    else
      _ -> false
    end
  end

  defp is_matching_crypto(%__MODULE__{crypto: spec_crypto}, only_crypto) do
    case normalize_crypto(only_crypto) do
      :any_crypto -> spec_crypto != false
      nil -> true
      crypto -> spec_crypto == crypto
    end
  end

  def to_bcan(%__MODULE__{} = spec, ican, separator \\ " ") do
    ican = ICAN.electronic_format(ican)

    with <<_cc::binary-size(4), rest::binary>> <- ican,
         groups when is_list(groups) <- Regex.run(spec.regex, rest, capture: :all_but_first) do
      {:ok, Enum.join(groups, separator)}
    else
      _ -> {:error, "ICAN does not match structure"}
    end
  end

  def from_bcan(%__MODULE__{} = spec, bcan) do
    bcan = ICAN.electronic_format(bcan)

    if is_valid_bcan(spec, bcan) do
      remainder =
        ICAN.iso7064_mod97(ICAN.iso13616_prepare(spec.country_code <> "00" <> bcan))

      check = (98 - remainder) |> Integer.to_string() |> String.pad_leading(2, "0")
      {:ok, spec.country_code <> check <> bcan}
    else
      {:error, "invalid BCAN"}
    end
  end

  def is_valid_bcan(%__MODULE__{} = spec, bcan, only_crypto \\ false) do
    bcan = ICAN.electronic_format(bcan)

    spec.length - 4 == String.length(bcan) and
      is_matching_crypto(spec, only_crypto) and
      Regex.match?(spec.regex, bcan)
  end
end
