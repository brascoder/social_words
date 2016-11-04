defmodule SocialLeven do
  def friends?(word1, word2) do
    do_distance(to_charlist(word1), to_charlist(word2), 0) == 1
  end

  defp do_distance(_word1, _word2, distance) when distance > 1, do: distance

  defp do_distance(word1, word2, distance) when word1 == word2, do: distance

  defp do_distance(word1, '', distance), do: distance + length(word1)

  defp do_distance('', word2, distance), do: distance + length(word2)

  defp do_distance([head1|tail1] = word1, [head2|tail2] = word2, distance) do
    Enum.min [
      do_distance(word1, tail2, distance + 1),
      do_distance(tail1, word2, distance + 1),
      do_distance(tail1, tail2, distance + compare(head1, head2))
    ]
  end

  defp compare(letter1, letter2) do
    case letter1 == letter2 do
      true  -> 0
      false -> 1
    end
  end
end


defmodule SocialWords do
  def parse_input(data) do
    File.stream!(data, [:read])
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(prep_agents, fn(word, pids) ->
      case word do
        "END OF INPUT" ->
          Map.put(pids, :end_of_input, true)
        _ ->
          add_word(word, pids)
      end
    end)
  end

  def network_count(word, list) do
    {:ok, test_case} = Agent.start_link(fn -> %{word: word, network: []} end)
    do_network(word, list, test_case)

    Agent.get(test_case, &Map.get(&1, :network))
    |> length
  end

  defp do_network(word, list, test_case) do
    Enum.each(list, fn w ->
      Agent.get(test_case, &Map.get(&1, :network))
      |> Enum.member?(w)
      |> case do
        true -> nil
        false ->
          case SocialLeven.friends?(word, w) do
            true ->
              Agent.update(test_case, &Map.update!(&1, :network, fn net -> [w|net] end))
              do_network(w, list, test_case)
            false -> nil
          end
      end
    end)
  end

  defp prep_agents do
    {:ok, test_pid} = Agent.start_link fn -> [] end
    {:ok, data_pid} = Agent.start_link fn -> [] end
    %{end_of_input: false, test: test_pid, data: data_pid}
  end

  defp add_word(word, pids) do
    case Map.get(pids, :end_of_input) do
      false ->
        Map.get(pids, :test)
        |> Agent.update(fn list -> [word | list] end)
      true ->
        Map.get(pids, :data)
        |> Agent.update(fn list -> [word | list] end)
    end
    pids
  end
end



data_file = "data.txt"
%{test: test, data: data} = SocialWords.parse_input(data_file)

Enum.each(Agent.get(test, fn list -> list end), fn test_word ->
  count = SocialWords.network_count(test_word, Agent.get(data, fn list -> list end))
  IO.puts "#{test_word}: #{count}"
end)
