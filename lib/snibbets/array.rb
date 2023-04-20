module Snibbets
  class ::Array
    def blocks
      select { |el| el =~ /^<block\d+>$/ }.count
    end

    def notes
      select { |el| el !~ /^<block\d+>$/ && el !~ /^```/ && !el.strip.empty? }.count
    end

    def strip_empty
      remove_leading_empty_elements.remove_trailing_empty_elements
    end

    def strip_empty!
      replace strip_empty
    end

    def remove_leading_empty_elements
      output = []

      in_leader = true
      each do |line|
        if (line.strip.empty?) && in_leader
          next
        else
          in_leader = false
          output << line
        end
      end

      output
    end

    def remove_trailing_empty_elements
      reverse.remove_leading_empty_elements.reverse
    end
  end
end
