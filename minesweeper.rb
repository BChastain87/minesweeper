class MinesweeperGame

    attr_reader :board

    def initialize(n)
        Board.new(n)
        @board = Board.new(n)
    end

    def start_game
        @board.bomb_placement
        @board.print_grid
        run
    end

    def play_turn
        @board.select_tile
        @board.print_grid
    end

    def run
        play_turn until @board.lost? || @board.won?
        puts "Congratulations, you win!"        
    end
end

class Board

    attr_reader :size, :lost

    def print_grid
        @grid.each do |row|
            puts row.join(" ")
        end    
    end

    def initialize(n)
        @grid = Array.new(n) {Array.new(n) {Tile.new}}
        @size = n * n
        @lost = false
        value_assigner
    end

    def lost?
        @lost        
    end

    def [](position)
        row, column = position
    end

    def []=(position, value)
        row, column = position
        @grid[row][column] = value
    end

    def won?
        # @grid.flatten.all? do |tile|
        #     tile.bomb? && tile.flag == true
        # end
        p @grid.flatten.none?{ |t| t.hidden? }
    end

    def bomb_placement
        #percentage of size
        bombs_count = @size * 0.25
        #place with bomb
        until @grid.flatten.count { |tile| tile.bomb? } >= bombs_count.floor
            @grid[rand_num_gen][rand_num_gen].add_bomb
        end
    end

    # def hidden_grid
    #     @grid.map do |row|
    #         row.map do |tile|
    #             if @hidden == false
    #                 tile.value
    #             elsif tile.flag == true
    #                 :F
    #             else
    #                 :M
    #             end
    #         end
    #     end
    # end

    def print
        @board.print_grid     
    end

    def rand_num_gen
        max = Math.sqrt(@size).to_i
        rand(0...max)
    end

    def select_tile
        puts "Select position by entering row and column (ex. 3,2)"
        guess = gets.chomp
        row, column = guess.split(",").map { |i| i.to_i }    
        if @grid[row][column].bomb?
            @lost = true
        else
            @grid[row][column].hidden = false
        end
    end

    def value_assigner
        max = Math.sqrt(@size).to_i
        (0...max).each do |row|
            (0...max).each do |ele|
        #assign value based on adjacent tiles
                bomb_count = bomb_counter(row, ele)
                if bomb_count == 0
                    []
                else
                    @grid[row][ele].value = bomb_count
                end
            end
        end
    end

    def bomb_counter(row, ele)
        # Math.min(size.sqrt, row+1)
        # Math.max(0, row-1)
        min_row = [0, row-1].max
        max_row = [Math.sqrt(@size), row+1].min
        min_ele = [0, ele-1].max
        max_ele = [Math.sqrt(@size), ele+1].max
        count = 0
        (min_row...max_row).each do |r|
            (min_ele...max_ele).each do |e|
                if @grid[r][e].bomb?
                    count += 1
                end
            end
        end
        count
    end
end

class Tile

    attr_accessor :value, :hidden, :flag

    def initialize
        @hidden = true
        @flag = false
        @bomb = false
        @value = value
    end

    def add_bomb
        @bomb = true        
    end

    def bomb?
        @bomb
    end

    def hidden?
        @hidden        
    end

    def hide
        @hidden = false
    end

    def flag
        @flag = true
    end

    def to_s
        if @hidden
            "M"
        elsif @flag
            "F"
        else
            @value || 0
        end
    end    
end

game = MinesweeperGame.new(9)
game.start_game