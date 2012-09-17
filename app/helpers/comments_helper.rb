# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

module CommentsHelper
  # comments comes in as a set of nested hashes via ancestry's arrange method 
  # to denote parent and children comments
  # if parent_comment exists, it means we are looking at a dedicated page for a comment and it's children
  def nested_comments(comments, parent_comment = nil)
    comments.map do |comment, sub_comments|
      # we don't want to show comments of blocked learners (eg. marked as spam, inappropriate, etc.) and
      # we don't want to show any of the child comments of such comments
      if comment.created_by_blocked_learner?
        next
      end
      render('/comments/comment', {:comment => comment, :parent_comment => parent_comment}) + content_tag(:div, nested_comments(sub_comments, parent_comment), :class => "nested_comments")
    end.join.html_safe  
  end

  def comment_class(comment)
    if(current_learner and @last_viewed_at)
      if(@last_viewed_at - 5.minutes < comment.updated_at and comment.learner_id != current_learner.id)
        'comment new'
      else
        'comment'
      end
    else
      'comment'
    end
  end
end
