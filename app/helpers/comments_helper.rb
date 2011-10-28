module CommentsHelper
  # comments comes in as a set of nested hashes via ancestry's arrange method 
  # to denote parent and children comments
  # if parent_comment exists, it means we are looking at a dedicated page for a comment and it's children
  def nested_comments(comments, parent_comment = nil)
    comments.map do |comment, sub_comments|
      render(comment, {:parent_comment => parent_comment}) + content_tag(:div, nested_comments(sub_comments, parent_comment), :class => "nested_comments")
    end.join.html_safe  
  end
end
