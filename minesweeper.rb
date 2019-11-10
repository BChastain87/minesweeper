class MinesweeperGame

    attr_reader :board

    def initialize(n)
        Board.new(n)
        @board = Board.new(n)
    end

    def start_game
        @board.bomb_placement
        @board.print
        run
    end

    def play_turn
        @board.select_tile
        @board.print
    end

    def run
        play_turn until @board.lost? || @board.won?
    end
end

class Board

    attr_reader :size, :lost

    def print_grid(grid)
        grid.each do |row|
            puts row.join(" ")
        end    
    end

    def initialize(n)
        @grid = Array.new(n) {Array.new(n) {Tile.new}}
        @size = n * n
        @lost = false
        bomb_placement
        value_assigner
        
    end

    def lost?
        if @lost == true
            puts "You picked a bomb. You lose, Game Over!"
            true
        end 
    end

    def [](position)
        row, column = position
    end

    def []=(position, value)
        row, column = position
        @grid[row][column] = value
    end

    def won?
        all_nonbomb_tiles = @grid.flatten.select { |tile| tile.bomb? == false }
            if all_nonbomb_tiles.all? { |tile| tile.hidden? == false }
                puts "Congratulations, you win!" 
                true 
            end
        # @grid.flatten.none?{ |t| t.hidden? }
    end

    def bomb_placement
        #percentage of size
        bombs_count = @size * 0.1
        #place with bomb
        until @grid.flatten.count { |tile| tile.bomb? } >= bombs_count.ceil
            @grid[rand_num_gen][rand_num_gen].add_bomb
        end
    end

    def hidden_grid
        @grid.map do |row|
            row.map do |tile|
                if tile.hidden == false
                    tile.value
                elsif tile.flag? == true
                    "F"
                else
                    "M"
                end
            end
        end
    end

    def print
        self.print_grid(hidden_grid)     
    end

    def rand_num_gen
        max = Math.sqrt(@size).to_i
        rand(0...max)
    end

    def select_tile
        puts "Select position by entering row and column (ex. 3,2)"
        guess_pos = gets.chomp
        puts "Put 1 = Reveal, 2 = Flag / Unflag"
        function_to_position_guessed = gets.chomp.to_i
        row, column = guess_pos.split(",").map { |i| i.to_i }    
        if function_to_position_guessed == 1
           if @grid[row][column].bomb?
                reveal_all
                @lost = true
           elsif @grid[row][column].value == " "
                empty_space_checker(row, column)
                @grid[row][column].hidden = false
            else
                @grid[row][column].hidden = false
            end
        elsif function_to_position_guessed == 2
            @grid[row][column].toggle_flag
        elsif function_to_position_guessed == 5
            reveal_all
        end
    end

    def value_assigner
        max = Math.sqrt(@size).to_i
        (0...max).each do |row|
            (0...max).each do |ele|
        #assign value based on adjacent tiles
                bomb_count = bomb_counter(row, ele)
                tile = @grid[row][ele]
                if tile.bomb? == true
                    tile.value_set("B")
                elsif bomb_count == 0 && tile.bomb? == false
                    @grid[row][ele].value_set(" ")
                else
                    @grid[row][ele].value_set(bomb_count)
                end
            end
        end
    end

    def bomb_counter(row, ele)
        min_row = [0, row-1].max
        max_row = [Math.sqrt(@size)-1, row+1].min
        min_ele = [0, ele-1].max
        max_ele = [Math.sqrt(@size)-1, ele+1].min
        count = 0
        (min_row..max_row).each do |r|
            (min_ele..max_ele).each do |e|
                if @grid[r][e].bomb?
                    count += 1
                end
            end
        end
        count
    end

    def empty_space_checker(row, ele)
        min_row = [0, row-1].max
        max_row = [Math.sqrt(@size)-1, row+1].min
        min_ele = [0, ele-1].max
        max_ele = [Math.sqrt(@size)-1, ele+1].min
        empty_tiles = []
        root_tiles = []
        (min_row..max_row).each do |r|
            (min_ele..max_ele).each do |e|
                if root_tiles.include?([r,e]) || @grid[r][e].hidden? == false
                    next
                elsif @grid[r][e].value == " " && @grid[r][e].hidden? == true
                      @grid[r][e].hide
                      empty_tiles << [r,e]
                elsif @grid[r][e].value != "B"
                    @grid[r][e].hide
                end
            end
            root_tiles << [row, ele]
        end

        
        until empty_tiles.empty?
            first, second = empty_tiles.shift
                empty_space_checker(first, second)
        end
    end

    def reveal_all
        @grid.flatten.each { |ele| ele.hide }
    end
end

class Tile

    attr_accessor :value, :hidden, :flag

    def initialize
        @hidden = true
        @flag = false
        @bomb = false
        @value = 0
    end

    def value_set(num)
        @value = num
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

    def flag?
        @flag
    end

    def toggle_flag
        if @flag == false
            @flag = true
        else
            @flag = false
        end
    end

    def to_s
        if @hidden == true
            "M"
        elsif @flag == true
            "F"
        else
            @value || 0
        end
    end    
end

game = MinesweeperGame.new(9)
game.start_game