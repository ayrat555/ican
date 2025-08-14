defmodule ICAN do
  @moduledoc """
  ICAN utilities for validation, formatting, and conversion to/from BCAN.

  Supports International Crypto Account Numbers (ICAN) and Basic Crypto Account Numbers (BCAN).
  Includes official ICAN registry countries and digital assets with crypto-specific formats.
  """

  alias ICAN.Specification

  @non_alphanum ~r/[^a-zA-Z0-9]/
  @every_four_chars ~r/.{4}(?!$)/

  @type crypto :: :main | :test | :enter | false
  @type spec :: Specification.t()

  # Define country specifications statically

  @countries_specs %{
    "QA" => {29, "U04A21", false, "QA30AAAA123456789012345678901"},
    "MR" => {27, "F05F05F11F02", false, "MR1300020001010000123456753"},
    "CH" => {21, "F05A12", false, "CH9300762011623852957"},
    "AO" => {25, "F21", false, "AO69123456789012345678901"},
    "HU" => {28, "F03F04F01F15F01", false, "HU42117730161111101800000000"},
    "AZ" => {28, "U04A20", false, "AZ21NABZ00000000137010001944"},
    "BY" => {28, "A04F04A16", false, "BY13NBRB3600900000002Z00AB00"},
    "MZ" => {25, "F21", false, "MZ25123456789012345678901"},
    "TR" => {26, "F05F01A16", false, "TR330006100519786457841326"},
    "PL" => {28, "F08F16", false, "PL61109010140000071219812874"},
    "AT" => {20, "F05F11", false, "AT611904300234573201"},
    "SV" => {28, "U04F20", false, "SV62CENR00000000000000700025"},
    "RE" => {27, "F05F05A11F02", false, "RE131234512345123456789AB13"},
    "LI" => {21, "F05A12", false, "LI21088100002324013AA"},
    "GI" => {23, "U04A15", false, "GI75NWBK000000007099453"},
    "CV" => {25, "F21", false, "CV30123456789012345678901"},
    "SK" => {24, "F04F06F10", false, "SK3112000000198742637541"},
    "LT" => {20, "F05F11", false, "LT121000011101001000"},
    "AL" => {28, "F08A16", false, "AL47212110090000000235698741"},
    "BL" => {27, "F05F05A11F02", false, "BL391234512345123456789AB13"},
    "VG" => {24, "U04F16", false, "VG96VPVG0000012345678901"},
    "GE" => {22, "U02F16", false, "GE29NB0000000101904917"},
    "GB" => {22, "U04F06F08", false, "GB29NWBK60161331926819"},
    "CB" => {44, "H40", "main", "CB661234567890ABCDEF1234567890ABCDEF12345678"},
    "IL" => {23, "F03F03F13", false, "IL620108000000099999999"},
    "LU" => {20, "F03A13", false, "LU280019400644750000"},
    "AB" => {44, "H40", "test", "AB841234567890ABCDEF1234567890ABCDEF12345678"},
    "MC" => {27, "F05F05A11F02", false, "MC5811222000010123456789030"},
    "AD" => {24, "F04F04A12", false, "AD1200012030200359100100"},
    "IQ" => {23, "U04F03A12", false, "IQ98NBIQ850123456789012"},
    "KW" => {30, "U04A22", false, "KW81CBKU0000000000001234560101"},
    "EE" => {20, "F02F02F11F01", false, "EE382200221020145685"},
    "IS" => {26, "F04F02F06F10", false, "IS140159260076545510730339"},
    "AE" => {23, "F03F16", false, "AE070331234567890123456"},
    "CM" => {27, "F23", false, "CM9012345678901234567890123"},
    "MD" => {24, "U02A18", false, "MD24AG000225100013104168"},
    "SA" => {24, "F02A18", false, "SA0380000000608010167519"},
    "MK" => {19, "F03A10F02", false, "MK07250120000058984"},
    "LC" => {32, "U04F24", false, "LC07HEMM000100010012001200013015"},
    "SI" => {19, "F05F08F02", false, "SI56263300012039086"},
    "CZ" => {24, "F04F06F10", false, "CZ6508000000192000145399"},
    "NO" => {15, "F04F06F01", false, "NO9386011117947"},
    "NC" => {27, "F05F05A11F02", false, "NC551234512345123456789AB13"},
    "BE" => {16, "F03F07F02", false, "BE68539007547034"},
    "LV" => {21, "U04A13", false, "LV80BANK0000435195001"},
    "GT" => {28, "A04A20", false, "GT82TRAJ01020000001210029690"},
    "DZ" => {24, "F20", false, "DZ8612345678901234567890"},
    "KZ" => {20, "F03A13", false, "KZ86125KZT5004100100"},
    "GL" => {18, "F04F09F01", false, "GL8964710001000206"},
    "SN" => {28, "U01F23", false, "SN52A12345678901234567890123"},
    "JO" => {30, "A04F22", false, "JO15AAAA1234567890123456789012"},
    "MT" => {31, "U04F05A18", false, "MT84MALT011000012345MTLCAST001S"},
    "BI" => {16, "F12", false, "BI41123456789012"},
    "BA" => {20, "F03F03F08F02", false, "BA391290079401028494"},
    "MQ" => {27, "F05F05A11F02", false, "MQ221234512345123456789AB13"},
    "MU" => {30, "U04F02F02F12F03U03", false, "MU17BOMM0101101030300200000MUR"},
    "YT" => {27, "F05F05A11F02", false, "YT021234512345123456789AB13"},
    "ML" => {28, "U01F23", false, "ML15A12345678901234567890123"},
    "BH" => {22, "U04A14", false, "BH67BMAG00001299123456"},
    "LB" => {28, "F04A20", false, "LB62099900000001001901229114"},
    "GR" => {27, "F03F04A16", false, "GR1601101250000000012300695"},
    "GP" => {27, "F05F05A11F02", false, "GP791234512345123456789AB13"},
    "BF" => {27, "F23", false, "BF2312345678901234567890123"},
    "ME" => {22, "F03F13F02", false, "ME25505000012345678951"},
    "PK" => {24, "U04A16", false, "PK36SCBL0000001123456702"},
    "SE" => {24, "F03F16F01", false, "SE4550000000058398257466"},
    "SC" => {31, "U04F04F16U03", false, "SC18SSCB11010000000000001497USD"},
    "PF" => {27, "F05F05A11F02", false, "PF281234512345123456789AB13"},
    "HR" => {21, "F07F10", false, "HR1210010051863000160"},
    "RS" => {22, "F03F13F02", false, "RS35260005601001611379"},
    "IE" => {22, "U04F06F08", false, "IE29AIBK93115212345678"},
    "CE" => {44, "H40", "enter", "CE571234567890ABCDEF1234567890ABCDEF12345678"},
    "VA" => {22, "F18", false, "VA59001123000012345678"},
    "IR" => {26, "F22", false, "IR861234568790123456789012"},
    "NL" => {18, "U04F10", false, "NL91ABNA0417164300"},
    "FI" => {18, "F06F07F01", false, "FI2112345600000785"},
    "UA" => {29, "F25", false, "UA511234567890123456789012345"},
    "ST" => {25, "F08F11F02", false, "ST68000100010051845310112"},
    "FR" => {27, "F05F05A11F02", false, "FR1420041010050500013M02606"},
    "TL" => {23, "F03F14F02", false, "TL380080012345678910157"},
    "DE" => {22, "F08F10", false, "DE89370400440532013000"},
    "DO" => {28, "U04F20", false, "DO28BAGR00000001212453611324"},
    "WF" => {27, "F05F05A11F02", false, "WF621234512345123456789AB13"},
    "GF" => {27, "F05F05A11F02", false, "GF121234512345123456789AB13"},
    "ES" => {24, "F04F04F01F01F10", false, "ES9121000418450200051332"},
    "SM" => {27, "U01F05F05A12", false, "SM86U0322509800000000270100"},
    "BG" => {22, "U04F04F02A08", false, "BG80BNBG96611020345678"},
    "MF" => {27, "F05F05A11F02", false, "MF551234512345123456789AB13"},
    "CR" => {22, "F04F14", false, "CR72012300000171549015"},
    "CI" => {28, "U02F22", false, "CI70CI1234567890123456789012"},
    "PT" => {25, "F04F04F11F02", false, "PT50000201231234567890154"},
    "PS" => {29, "U04A21", false, "PS92PALS000000000400123456702"},
    "CY" => {28, "F03F05A16", false, "CY17002001280000001200527600"},
    "TN" => {24, "F02F03F13F02", false, "TN5910006035183598478831"},
    "XK" => {20, "F04F10F02", false, "XK051212012345678906"},
    "DK" => {18, "F04F09F01", false, "DK5000400440116243"},
    "FO" => {18, "F04F09F01", false, "FO6264600001631634"},
    "RO" => {24, "U04A16", false, "RO49AAAA1B31007593840000"},
    "EG" => {29, "F04F04F17", false, "EG800002000156789012345180002"},
    "PM" => {27, "F05F05A11F02", false, "PM071234512345123456789AB13"},
    "BJ" => {28, "F24", false, "BJ39123456789012345678901234"},
    "BR" => {29, "F08F05F10U01A01", false, "BR9700360305000010009795493P1"},
    "MG" => {27, "F23", false, "MG1812345678901234567890123"},
    "IT" => {27, "U01F05F05A12", false, "IT60X0542811101000000123456"},
    "TF" => {27, "F05F05A11F02", false, "TF891234512345123456789AB13"}
  }

  # -- Public API -------------------------------------------------------------

  @doc """
  Validates an ICAN. Returns `true` if valid, `false` otherwise.

  `only_crypto` can be:
  - `false` (default): Ignores crypto status.
  - `true`: Matches any crypto-enabled ICAN.
  - `:main`, `:test`, `:enter`, or their string equivalents ("main", "mainnet", "test", "testnet", "enter", "enterprise").

  ## Examples
      iex> ICAN.is_valid("DE89370400440532013000")
      true
      iex> ICAN.is_valid("CB661234567890ABCDEF1234567890ABCDEF12345678", :main)
      true
      iex> ICAN.is_valid("DE89370400440532013000", :main)
      false
  """
  @spec is_valid(String.t(), boolean() | String.t() | atom()) :: boolean()
  def is_valid(ican, only_crypto \\ false)
  def is_valid(ican, _only_crypto) when not is_binary(ican), do: false

  def is_valid(ican, only_crypto) do
    ican = electronic_format(ican)

    with <<cc::binary-size(2), _rest::binary>> <- ican,
         {:ok, spec} <- get_specification(cc) do
      Specification.is_valid(spec, ican, only_crypto)
    else
      _ -> false
    end
  end

  @doc """
  Converts an ICAN to BCAN, joining structure groups with `separator` (default: space).

  Returns `{:ok, bcan}` or `{:error, reason}`.

  ## Examples
      iex> ICAN.to_bcan("DE89370400440532013000")
      {:ok, "37040044 0532013000"}
      iex> ICAN.to_bcan("INVALID")
      {:error, "invalid country code"}
  """
  @spec to_bcan(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def to_bcan(ican, separator \\ " ") do
    ican = electronic_format(ican)

    with <<cc::binary-size(2), _::binary>> <- ican,
         {:ok, spec} <- get_specification(cc) do
      Specification.to_bcan(spec, ican, separator)
    else
      _ -> {:error, "invalid country code"}
    end
  end

  @doc """
  Creates a full ICAN from a `country_code` and a `bcan` by computing check digits.

  Returns `{:ok, ican}` or `{:error, reason}`.

  ## Examples
      iex> ICAN.from_bcan("DE", "370400440532013000")
      {:ok, "DE89370400440532013000"}
      iex> ICAN.from_bcan("XX", "370400440532013000")
      {:error, "invalid country code"}
  """
  @spec from_bcan(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def from_bcan(country_code, bcan) do
    case get_specification(country_code) do
      {:ok, spec} -> Specification.from_bcan(spec, bcan)
      _ -> {:error, "invalid country code"}
    end
  end

  @doc """
  Validates a BCAN against a country's specification.

  `only_crypto` options are the same as `is_valid/2`.

  ## Examples
      iex> ICAN.is_valid_bcan("DE", "370400440532013000")
      true
      iex> ICAN.is_valid_bcan("DE", "INVALID")
      false
  """
  @spec is_valid_bcan(String.t(), String.t(), boolean() | String.t() | atom()) :: boolean()
  def is_valid_bcan(country_code, bcan, only_crypto \\ false) do
    case get_specification(country_code) do
      {:ok, spec} -> Specification.is_valid_bcan(spec, electronic_format(bcan), only_crypto)
      _ -> false
    end
  end

  @doc """
  Converts a string to electronic format: strips non-alphanumerics and converts to uppercase.

  ## Examples
      iex> ICAN.electronic_format("DE89 3704 0044 0532 0130 00")
      "DE89370400440532013000"
  """
  @spec electronic_format(String.t()) :: String.t()
  def electronic_format(str) when is_binary(str) do
    str
    |> String.replace(@non_alphanum, "")
    |> String.upcase()
  end

  @doc """
  Pretty-prints an ICAN with a separator every 4 characters (default: space).

  ## Examples
      iex> ICAN.print_format("DE89370400440532013000")
      "DE89 3704 0044 0532 0130 00"
  """
  @spec print_format(String.t(), String.t()) :: String.t()
  def print_format(ican, separator \\ " ") do
    str = electronic_format(ican)
    Regex.replace(@every_four_chars, str, "\\0" <> separator)
  end

  @doc """
  Formats an ICAN as a short string like `AAAA…BBBB`.

  `front_count` and `back_count` specify how many characters to show (default: 4 each).

  ## Examples
      iex> ICAN.short_format("DE89370400440532013000")
      "DE89…3000"
      iex> ICAN.short_format("DE89370400440532013000", "-", 6, 6)
      "DE8937-013000"
  """
  @spec short_format(String.t(), String.t(), non_neg_integer(), non_neg_integer()) :: String.t()
  def short_format(ican, separator \\ "…", front_count \\ 4, back_count \\ 4) do
    formatted = electronic_format(ican)

    if front_count >= 0 and back_count >= 0 and
         front_count + back_count <= String.length(formatted) do
      front = String.slice(formatted, 0, front_count)
      back = String.slice(formatted, -back_count, back_count)
      front <> separator <> back
    else
      raise ArgumentError, "invalid front_count or back_count"
    end
  end

  # -- Internal helpers (ISO 13616 / 7064) -----------------------------------

  @doc false
  def iso13616_prepare(ican) do
    <<head::binary-size(4), tail::binary>> = ican

    (tail <> head)
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.map_join(fn c ->
      if c >= ?A and c <= ?Z, do: Integer.to_string(c - ?A + 10), else: <<c>>
    end)
  end

  @doc false
  def iso7064_mod97(digits) when is_binary(digits) do
    digits
    |> String.to_charlist()
    |> Enum.reduce(0, fn digit, acc ->
      rem(acc * 10 + (digit - ?0), 97)
    end)
  end

  # -- Country / Asset specifications ----------------------------------------

  @doc """
  Returns a map of country/asset code (2 letters) to %Specification{}.

  ## Examples
      iex> map = ICAN.countries()
      iex> is_map(map) and map["DE"]
      %ICAN.Specification{country_code: "DE", ...}
  """
  @spec countries() :: %{String.t() => spec()}
  def countries do
    Enum.map(@countries_specs, fn {country_code, {len, structure, crypto, example}} ->
      {:ok, spec} = Specification.new(country_code, len, structure, crypto, example)

      spec
    end)
  end

  @spec get_specification(String.t()) :: {:ok, spec()} | {:error, String.t()}
  def get_specification(country_code) do
    with :ok <- Specification.validate_country_code(country_code),
         spec when not is_nil(spec) <- Map.get(@countries_specs, country_code) do
      {len, structure, crypto, example} = spec
      Specification.new(country_code, len, structure, crypto, example)
    else
      _ -> {:error, "invalid country code"}
    end
  end
end
