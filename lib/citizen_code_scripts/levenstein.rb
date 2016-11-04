class Levenstein
  def self.edit_distance(s, t)
    return t.size if s.empty?
    return s.size if t.empty?
    return [(edit_distance s.chop, t) + 1,
            (edit_distance s, t.chop) + 1,
            (edit_distance s.chop, t.chop) + (s[-1, 1] == t[-1, 1] ? 0 : 1)
    ].min
  end

  def self.closest_match(needle, haystack)
    min_distance = haystack.map(&:size).max
    results = nil
    haystack.each do |value|
      distance = edit_distance(needle, value)
      if distance < min_distance
        min_distance = distance
        results = [value]
      elsif distance == min_distance
        results << value
      end
    end
    results
  end
end