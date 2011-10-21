# === COPYRIGHT:
# Copyright (c) North Carolina State University
# Developed with funding for the National eXtension Initiative.
# === LICENSE:
# see LICENSE file

require 'test_helper'

class TagTest < ActiveSupport::TestCase

  context "Creating a new tag" do
    should validate_presence_of(:name)
    should have_many(:taggings)
  end
  
  context "Creating a new tag with an existing tag" do
    # needs a db record
    setup do
      @tag = Factory.create(:tag)
    end    
    should validate_uniqueness_of(:name)
  end
  
  context "Given a set of normalized strings, the strings" do
    setup do
      @strings = ['term','two terms','colon:delimted-with-hyphens','alpha12345numerics']
    end
  
    should "be equal after normalization" do
      @strings.each do |string|
        assert_equal(string,Tag.normalizename(string))
      end
    end
  end
  
  context "Given a set of non-normalized strings, the strings" do
    setup do
      @strings = ['$term','test:term#','amazing!','(test term)']
    end
  
    should "not contain characters allowed by the core regular expression" do
      @strings.each do |string|
        assert_no_match(%r{[^\w :-]},Tag.normalizename(string))
      end
    end
  end
  
  context "Given a set of strings, the strings" do
    setup do
      @underscore_string = "term1_term2"
      @multispace_string = "term1  term2   term3"
      @leading_trailing_space_string = "   term1  "
    end
    
    should "have underscores converted to spaces" do
      assert_equal(@underscore_string.gsub('_',' '),Tag.normalizename(@underscore_string))
    end
    
    should "have multiple spaces converted to single spaces" do
      assert_equal(@multispace_string.gsub(/ {2,}/,' '),Tag.normalizename(@multispace_string))
    end  

    should "have leading and trailing spaces removed" do
      assert_equal(@leading_trailing_space_string.strip,Tag.normalizename(@leading_trailing_space_string))
    end
  end    
    
  
end
