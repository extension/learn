# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file


class LearnersIndex < Chewy::Index
  define_type Learner do
    field :name, type: 'text'
    field :retired, type: 'boolean'
  end


  def self.by_name(name)
    query(match: {name: name})
  end

  def self.not_retired
    query(match: {retired: false})
  end

end
