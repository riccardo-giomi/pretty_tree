# frozen_string_literal: true

# Defines how a node label is formatted in the string ouput.
#
# This is the default behaviour:
# - for labels call #inspect on the value, then truncate to min_width.
module PrettyTree
  class Formatter
    class Default < PrettyTree::Formatter
      # Format as inspect, then truncate with "..." if max_width allows.
      def label(value, max_width: nil)
        text = value.inspect
        return text if max_width.nil? || text.length <= max_width
        return text[0, max_width] if max_width <= 3
        "#{text[0, max_width - 3]}..."
      end
    end
  end
end
