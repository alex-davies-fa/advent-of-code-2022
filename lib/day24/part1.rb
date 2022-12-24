require 'csv'
require 'pp'

module Day24
  class Part1
    WIND_MAP = {
      '>'=> [0,1],
      '<'=> [0,-1],
      '^'=> [-1,0],
      'v'=> [1,0],
    }

    def run(input_file)
      wind = read_input(input_file)
      @width = wind.keys.map{_1[1]}.max + 1
      @height = wind.keys.map{_1[0]}.max + 1

      @wind_time = [wind]

      @start = [-1,0]
      @goal = [@height, @width-1]
      max_time = 2

      queue = [[@start,0]]

      while true
        pos, time = queue.shift

        if time > max_time
          max_time = time
          queue = queue.sort_by { |s| manhat(s[0], @goal) }
          if time % 10 == 0
            queue = queue.first(50)
          end
            max_dist = manhat(queue.last[0], @goal)
            min_dist = manhat(queue.first[0], @goal)
          puts "T: #{time}, Queue: #{queue.length}, Best: #{min_dist}, Worst: #{max_dist}"
        end

        if pos == @goal
          pp time
          break
        end

        new_wind = wind_at(time+1)
        new_positions = next_positions(pos, new_wind)

        new_positions.each do |new_position|
          queue << [new_position, time+1] unless queue.include?([new_position, time+1])
        end
      end

      nil
    end

    def manhat(p1,p2)
      (p1[0]-p2[0]).abs + (p1[1]-p2[1]).abs
    end

    def next_positions(pos, wind)
      y,x = pos
      potentials = [[y+0,x+0],[y+1,x+0],[y-1,x+0],[y+0,x+1],[y+0,x-1]]
      wind_set = Set.new(wind.keys)
      potentials.reject do |p|
        legal_pos = (p == @start || p == @goal) || (p[0] >= 0 && p[1] >= 0 && p[0] < @height && p[1] < @width)
        !legal_pos || wind_set.include?([p[0],p[1]])
      end
    end

    def wind_at(time)
      @wind_time[time] ||= next_wind(@wind_time[time-1])
    end

    def next_wind(wind)
      new_wind = Hash.new { |h,k| h[k] = [] }
      wind.each do |p, dirs|
        dirs.each do |d|
          np = [p[0]+d[0], p[1]+d[1]]
          np[0] = 0 if np[0] == @height
          np[0] = @height-1 if np[0] == -1
          np[1] = 0 if np[1] == @width
          np[1] = @width-1 if np[1] == -1
          new_wind[np] << d
        end
      end
      new_wind
    end

    def print_state(wind, pos)
      char_map = WIND_MAP.invert

      for y in -1..@height
        for x in -1..@width
          if x == -1 || y == -1 || x == @width || y == @height
            print '#'
          elsif [y,x] == pos
            print 'E'
          elsif !wind.key?([y,x])
            print '.'
          elsif wind[[y,x]].length > 1
            print wind[[y,x]].length
          else
            print char_map[wind[[y,x]].first]
          end
        end
        print "\n"
      end
      puts
    end

    def read_input(file)
      lines = File.readlines(file, chomp: true)[1...-1]

      wind = {}
      for y in 0...lines.length
        line = lines[y].chars[1...-1]
        for x in 0...line.length
          wind[[y,x]] = [WIND_MAP[line[x]]] if line[x] != '.'
        end
      end

      wind
    end
  end
end
