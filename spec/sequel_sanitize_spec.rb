require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Item < Sequel::Model; end

describe "SequelSanitize" do

  describe "base case" do
    before(:each) do
      Item.plugin :sanitize, :fields => [:name]
    end

    it "should be loaded using Model.plugin" do
      Item.plugins.should include(Sequel::Plugins::Sanitize)
    end
    
    it "should require a field array" do
      class Item2 < Sequel::Model; end
      lambda {Item2.plugin :sanitize}.should raise_error(ArgumentError, ":fields must be a non-empty array")      
    end

    it "should require a sanitizer to be a symbol or callable" do
      class Item2 < Sequel::Model; end
      lambda { Item2.plugin :sanitize, :fields => [:name], :sanitizer => 'xy' }.should raise_error(ArgumentError, "If you provide :sanitizer it must be Symbol or callable.")
    end

    it "should by default remove white space" do
      i = Item.new(:name => "     Kevin  ")
      i.name.should eql "Kevin"
    end
  end
  
  describe "downcase option" do
    before(:each) do
      Item.plugin :sanitize, :fields => [:name]
    end

    it "should optionally downcase a field" do
      Item.plugin :sanitize, :fields => [:name], :downcase => true
      i = Item.new(:name => "    eMaIL@adDRESs.com   ")
      i.name.should eql "email@address.com"
    end
  end

  describe "field handling" do
    it 'should remove nil field names' do
      class Item2 < Sequel::Model; end
      Item2.plugin :sanitize, :fields => [:name, nil]
      Item2.sanitize_options[:fields].should eql [:name]
    end
  
    it 'should remove duplicate fields' do
      class Item2 < Sequel::Model; end
      Item2.plugin :sanitize, :fields => [:name, :slug, :name]
      Item2.sanitize_options[:fields].count.should eql 2
    end
    
    it 'should add to the field list on multiple calls' do
      #not overwrite fields when you add more fields with different options
      class Item2 < Sequel::Model; end
      Item2.plugin :sanitize, :fields => [:name]
      Item2.plugin :sanitize, :fields => [:slug]
      Item2.plugin :sanitize, :fields => [:more, :columns, :name]
      Item2.sanitize_options[:fields].should eql [:name, :slug, :more, :columns]
    end
    
    it 'should aggregate the values of field options' do
      class Item2 < Sequel::Model; end
      Item2.plugin :sanitize, :fields => [:name, :slug]
      Item2.plugin :sanitize, :fields => [:name], :downcase => true
      Item2.plugin :sanitize, :fields => [:slug], :sanitizer => :not_real
      Item2.sanitize_options[:field_sanitize][:name].should eql :sanitize_field
      Item2.sanitize_options[:field_sanitize][:slug].should eql :not_real
      Item2.sanitize_options[:field_downcase][:name].should be_true
      Item2.sanitize_options[:field_downcase][:slug].should be_false
    end
  end
end
