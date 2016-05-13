require 'set'
require 'byebug'

class Game

    def initialize
    end

end

class Tile

  attr_reader :flagged, :bomb, :showing, :adj_bombs

  def initialize
    @flagged, @bomb, @showing  = false, false, false
    @adj_bombs = 0
  end

  def hidden?
    @showing == false
  end

  def safe?
    @bomb == false
  end

  def reveal
    @showing = true
  end

  def unflag
    @flagged = false
  end

  def flag
    @flagged = true
  end

  def make_bomb
    @bomb = true
  end

  def valid?
    @flagged == false
  end

end

class Board

  attr_reader :grid

  def initialize
    @grid = Array.new(9) { Array.new(9) { Tile.new } }
    @seen_tiles = Set.new
  end

  def solved?
    @grid.each do |row|
      row.each do |tile|
        return false if tile.safe? && tile.hidden?
      end
    end
    true
  end

  def find_neighbors(position)
    x, y = position
    left_x = x - 1
    down_y = y - 1
    return [] if left_x < 0 && down_y < 0
    if left_x < 0 && down_y > 0
      up = @grid[x][y+1]
      right = @grid[x+1][y]
      down = @grid[x][y-1]
      neighbors = [down, up, right].reject { |tile| tile.nil? }
    elsif down_y < 0
      up = @grid[x][y+1]
      left = @grid[x-1][y]
      right = @grid[x+1][y]
      neighbors = [left, up, right].reject { |tile| tile.nil? }
    else
      up = @grid[x][y+1]
      left = @grid[x-1][y]
      right = @grid[x+1][y]
      down = @grid[x][y-1]
      neighbors = [up, left, down, right].reject { |tile| tile.nil? }
    end
    neighbors.shuffle
  end
    # neighbors.each { |tile| @seen_tiles.add(tile) }

  # if left_x < 0 && down_y < 0
  #   up = @grid[x][y+1]
  #   right = @grid[x+1][y]
  #   # neighbors = [up, right].reject { |tile| tile.nil? }

  # been_checked?(tile) ||

  def no_duplicates(arr)
    return [] if arr.nil?

    arr.reject! { |tile| tile.nil? }
    arr
  end

  #||

  def been_checked?(tile)
    @seen_tiles.include?(tile)
  end

  def no_adj_bombs?(position)
    check = find_neighbors(position)

    return true if check.nil?
    check.each do |tile|
      return false if tile.bomb
    end
    true
  end

  def num_of_adj_bombs(position)
    return 0 if position.empty?
    bombs = 0
    check = find_neighbors(position)
    check.each { |tile| bombs +=1 if tile.bomb }
    bombs
  end

  def tile_position(target_tile)
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |tile, tile_idx|
        return [row_idx, tile_idx] if tile == target_tile
      end
    end
  end

  def cascade(position)
    debugger if solved?
    #keep going until adj tile is bomb
    #once adj_bomb found, change adj_bombs for tile
    x, y = position
    inputed_tile = @grid[x][y]
    return if inputed_tile.nil?
    @seen_tiles.add(inputed_tile)
    inputed_tile.reveal
    tiles_to_check = find_neighbors(position)
    tiles_to_check = no_duplicates(tiles_to_check)

    tiles_to_check.each do |tile|
      position = tile_position(tile)
      #break if neigbors empty
      if tile.safe? && no_adj_bombs?(position)
        tile.reveal
        cascade(position)
      elsif tile.safe?
        tile.adj_bombs = num_of_adj_bombs(position)
      end
    end
  end

  def render
    new_grid = Array.new(9) { Array.new(9) }
    @grid.each_index do |row_idx|
      @grid[row_idx].each_index do |tile_idx|
        tile = @grid[row_idx][tile_idx]
        new_grid[row_idx][tile_idx] = tile_display_value(tile)
      end
    end
    new_grid.each { |row| p row }
  end


  def tile_display_value(tile)
    if tile.showing && tile.adj_bombs == 0
      "_"
    elsif tile.showing
      tile.adj_bombs
    else
      "*"
    end
  end

end

new_board = Board.new
new_board.cascade([3, 3])
new_board.render
