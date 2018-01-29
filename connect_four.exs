defmodule ConnectFour do

  @board :board
  @rows 6
  @columns 7
  @win_size 4
  @player_1 "X"
  @player_2 "O"

  def init do

    Agent.start_link(fn -> MapSet.new end, name: @board)

    for row <- 1..@rows, col <- 1..@columns, do: Agent.update(@board, fn(board_set) ->
      MapSet.put board_set, %{column: col, row: row, player: ""}
    end)
  end

  def new_game do
    @board |>
      Agent.update(fn(board_set) ->
        MapSet.new( board_set, fn
          any -> %{column: any.column, player: "", row: any.row}
        end)
      end)
  end

  def get_status(row, column) do
    @board |>
      Agent.get( fn(board_set) ->
        Enum.find(board_set, &(&1.row == row && &1.column == column))
      end)
  end

  def set_spot(row, column, @player_1) do
    _set_spot(row, column, @player_1)
  end

  def set_spot(row, column, @player_2) do
    _set_spot(row, column, @player_2)
  end

  def set_spot(_, _, _) do
    IO.puts "Only players 'X' and 'O' accepted"
  end

  def show_board do
    Agent.get(@board, fn board_set -> board_set end)
  end

  def set_value(%{column: _, player: player, row: _}, _) when byte_size(player) > 0 do
    IO.inspect "Spot is Busy"
  end

  def set_value(%{column: col, player: _, row: row}, pl) do

    @board |>
      Agent.update(fn(board_set) ->
        MapSet.new( board_set, fn
          %{column: ^col, player: "", row: ^row} -> %{column: col, player: pl, row: row}
          any -> any
        end)
      end)
    IO.puts "ok, next turn"
  end

  def winner? do

    Enum.map([@player_1, @player_2], fn player ->
      show_board() |>
      Enum.filter( fn set ->
        set.player == player
      end) |>
      calculate_winner |> Enum.member?(true) |> say_hello_to_winner(player)
    end)

  end

  def calculate_winner player_set do

    Enum.map([:row, :column], fn type ->

      Enum.map(get_size_map(type), fn row ->
        Enum.filter(player_set, fn set ->
          set[type] >= row
        end) |> Enum.count
      end) |> Enum.member?(@win_size)
    end)
  end

  def get_size_map(:row), do: 1..@rows
  def get_size_map(:column), do: 1..@columns


  def say_hello_to_winner(true, player) do
    IO.puts("Congratulaion, player #{player} win! Please start a new game CountFor.Board.new_game")
  end

  def say_hello_to_winner(false, _), do: ""

  def put_player(map, set) do
    case Map.fetch(map, set.player) do
      {:ok, _} -> update_in(map, [set.player], &(&1 ++ [set]))
      :error -> Map.put(map, set.player, [set])
    end
  end

  defp _set_spot(row, column, player) do
    case get_status(row, column) do
      nil -> IO.puts "row and column does not exists"
      spot -> set_value(spot, player)
    end
    show_board()
  end

end
