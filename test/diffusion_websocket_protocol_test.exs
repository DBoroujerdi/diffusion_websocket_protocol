defmodule Diffusion.Websocket.ProtocolTest do
  use ExUnit.Case
  doctest Diffusion.Websocket.Protocol

  alias Diffusion.Websocket.Protocol.ConnectionResponse, as: ConnectionResponse
  alias Diffusion.Websocket.Protocol.DataMessage, as: DataMessage
  alias Diffusion.Websocket.Protocol, as: Protocol

  test "can decode connection response" do
    expected = %ConnectionResponse{type: 100, client_id: "C8D4048FA5712A3A-006740E900000004", version: 4}
    actual = Protocol.decode(<<"4\u{2}100\u{2}C8D4048FA5712A3A-006740E900000004">>)
    assert expected == actual
  end

  test "returns error when version is not an integer" do
    expected = {:error, :decode_failure}
    actual = Protocol.decode(<<"d\u{2}100\u{2}C8D4048FA5712A3A-006740E900000004">>)
    assert expected == actual
  end

  # TODO: test for match failure

  test "decodes data message with header" do
    actual = Protocol.decode(<<"\u{14}sportsbook/football/9935205/stats/score!o638\u{01}0 - 0">>)
    expected = %DataMessage{type: 20, headers: [<<"sportsbook/football/9935205/stats/score!o638">>], data: [<<"0 - 0">>]}
    assert actual == expected
  end

  test "decodes data message without headers" do
    # TODO: need to find an example
  end

  test "decodes client ping message" do
    bin = <<"\u{19}1484349590272\u{01}">>
    assert Protocol.decode(bin) == %DataMessage{type: 25, headers: ["1484349590272"], data: [""]}
  end

  # Encodeing

  test "encodes client ping" do
    expected = <<"\u{19}1484349590272\u{01}">>
    actual = Protocol.encode(%DataMessage{type: 25, headers: ["1484349590272"], data: [""]})
    assert actual == expected
  end

  test "encode" do
    data = %DataMessage{type: 20, headers: [<<"sportsbook/football/9935205/stats/score!o638">>], data: [<<"0 - 0">>]}
    actual =  Protocol.encode(data)
    expected = <<"\u{14}sportsbook/football/9935205/stats/score!o638\u{01}0 - 0">>
    assert actual == expected
  end
end
