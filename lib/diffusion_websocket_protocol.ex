defmodule Diffusion.Websocket.Protocol do

  defmodule ConnectionResponse do
    @type t :: connection_response

    @type connection_type     :: 100 | 105
    @type connection_response :: %ConnectionResponse{ type: connection_type,
                                                      client_id: String.t,
                                                      version: number}

    defstruct type: nil, client_id: nil, version: nil
  end

  defmodule DataMessage do
    @type t :: data_message

    @type data         :: binary
    @type header       :: binary
    @type message_type :: 20..48
    @type data_message ::  %DataMessage{ type: message_type,
                                         headers: [header],
                                         data: [data]}

    defstruct type: nil, headers: [], data: ""
  end


  @type connection_type     :: 100 | 105
  @type connection_response :: %ConnectionResponse{ type: connection_type,
                                                    client_id: String.t,
                                                    version: number}

  @type reason :: any()

  @doc """
  Decode a message binary in the form - TH...D...
  Where T is the message-type byte, H is optional header bytes seperated
  by field delimiters FD and D is the data bytes also seperated by field
  delimiters.
  """

  @spec decode(binary) :: DataMessage.t | ConnectionResponse.t | {:error, reason}

  def decode(<<>>), do: {:error, :empty_binary}

  def decode(<<type::integer, rest::binary>>) when type >= 20 and type <= 48 do
    case String.split(rest, "\u{01}") do
      [bin] when byte_size(bin) == 0 ->
        {:error, :no_data}
      [data] ->
        %DataMessage{type: type, data: split(data), headers: []}
      [headers, data] ->
        %DataMessage{type: type, data: split(data), headers: split(headers)}
    end
  end

  def decode(bin) when is_binary(bin) do
    <<
      version_bin  :: bytes-size(1), "\u{02}",
      type_bin     :: bytes-size(3), "\u{02}",
      client_id    :: binary
    >> = bin

    with {version, ""} <- Integer.parse(version_bin),
         {type, ""}    <- Integer.parse(type_bin)
      do %ConnectionResponse{type: type, client_id: client_id, version: version}
      else
        _ -> {:error, :decode_failure}
    end
  end


  @doc """
  Encode a diffusion message as a binary of the form TH...D...
  Where T is the message-type byte, H is optional header bytes seperated
  by field delimiters FD and D is the data bytes also seperated by field
  delimiters.
  """

  @spec encode(DataMessage.t) :: String.t | {:error, atom}

  def encode(%DataMessage{type: type, data: data, headers: []}) do
    Integer.to_string(type) <>  Enum.join(data, "\u{02}")
  end

  def encode(%DataMessage{type: type, data: data, headers: headers}) do
    Integer.to_string(type) <> Enum.join(headers, "\u{02}") <> "\u{01}" <> Enum.join(data, "\u{02}")
  end


  defp split(bin) do
    String.split(bin, "\u{02}")
  end

end
