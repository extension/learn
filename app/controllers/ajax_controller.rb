# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

class AjaxController < ApplicationController
  include ActionView::Helpers::NumberHelper
  def tags
    if params[:term]
      search_term = Tag.normalizename(params[:term])
      tags = Tag.used_at_least_once.where("name like ?", "%#{search_term}%").limit(12)
    else
      tags = Tag.used_at_least_once.order('created_at DESC').limit(12)
    end
    list = []
    tags.each do |t|
      list <<  Hash[ id: t.id, label: t.name, name: t.name, tag_count: "#{number_with_delimiter(t.tag_count, :delimiter => ',')}"] if t.name != search_term
    end
    
    tag_count_description = "not used yet"
    
    param_tag = Tag.used_at_least_once.find_by_name(search_term)
    if param_tag
      tag_count_description = number_with_delimiter(param_tag.tag_count, :delimiter => ',')
    end
    
    list.unshift(Hash[id: nil, label: search_term, name: search_term, tag_count: tag_count_description])
    render json: list
  end

end