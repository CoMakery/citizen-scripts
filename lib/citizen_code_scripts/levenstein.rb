class Levenstein
  def self.edit_distance(s, t)
    m = s.length
    n = t.length
    return m if n == 0
    return n if m == 0
    d = Array.new(m+1) { Array.new(n+1) }

    (0..m).each { |i| d[i][0] = i }
    (0..n).each { |j| d[0][j] = j }
    (1..n).each do |j|
      (1..m).each do |i|
        d[i][j] = if s[i-1] == t[j-1] # adjust index into string
          d[i-1][j-1] # no operation required
        else
          [d[i-1][j]+1, # deletion
           d[i][j-1]+1, # insertion
           d[i-1][j-1]+1, # substitution
          ].min
        end
      end
    end
    d[m][n]
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