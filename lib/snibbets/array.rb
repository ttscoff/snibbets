module Snibbets
  class ::Array
    def blocks
      select { |el| el =~ /^<block\d+>$/ }.count
    end

    def strip_empty
      remove_leading_empty_elements.remove_trailing_empty_elements
    end

    def strip_empty!
      replace strip_empty
    end

    def remove_leading_empty_elements
      output = []

      each do |line|
        next if line =~ /^\s*$/ || line.empty?

        output << line
      end

      output
    end

    def remove_trailing_empty_elements
      output = []

      reverse.each do |line|
        next if line =~ /^\s*$/ || line.empty?

        output << line
      end

      output.reverse
    end
  end
end
