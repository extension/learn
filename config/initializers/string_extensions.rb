# more appropriate integer conversion than to_i - will need a full integer (e.g. 400 vs. 4-H)
class String
  def cast_to_i
    begin
      Integer(self)
    rescue
      0
    end
  end
end