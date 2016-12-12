defmodule Chopsticks.Move do
  def decode(move) do
    type = convert_type_string(move["type"])
    data =
      case type do
        :touch -> convert_touch_data(move["data"])
        _ -> nil
      end

    {type, data}
  end

  defp convert_type_string("touch"), do: :touch
  defp convert_type_string("split"), do: :split
  defp convert_type_string("quit"), do: :quit
  defp convert_type_string(type), do: type

  defp convert_touch_data([player_direction, opponent_direction]) do
    {convert_direction(player_direction),
     convert_direction(opponent_direction)}
  end

  defp convert_direction("left"), do: :left
  defp convert_direction("right"), do: :right
end
