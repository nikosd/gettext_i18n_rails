# coding: utf-8
require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

class SimpleModel
  extend ActiveModel
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations

  attr_accessor :model_attribute
  validates :model_attribute, :presence => {:message => "translate me"}
end

module Namespace
  class NamespacedModel
    extend ActiveModel
    extend ActiveModel::Naming
    extend ActiveModel::Translation
  end
end

describe ActiveModel do
  before do
    FastGettext.current_cache = {}
  end

  describe ActiveModel::Name do

    describe :i18n_key do
      it "maps to Gettext" do
        SimpleModel.model_name.i18n_key.should == 'Simple model'
      end

      it "includes namespaces" do
        Namespace::NamespacedModel.model_name.i18n_key.should == 'Namespace|Namespaced model'
      end
    end

    describe :human do
      it "is translated through FastGettext" do
        SimpleModel.model_name.should_receive(:s_).with('Simple model').and_return("The human name")
        SimpleModel.model_name.human.should == 'The human name'
      end

      it "takes into account the namespaces with fallback" do
        Namespace::NamespacedModel.model_name.should_receive(:s_).with('Namespace|Namespaced model').and_return("Namespaced human name")
        Namespace::NamespacedModel.model_name.human.should == 'Namespaced human name'
      end
    end
  end

  # TODO : Remove this totally for Rails 3.1 were the method will get removed
  if SimpleModel.respond_to? :human_name
    describe :human_name do
      it "is translated through FastGettext" do
        FastGettext.stub!(:current_repository).and_return('Simple model'=>"The human name")
        SimpleModel.human_name.should == 'The human name'
      end
    end
  end

  describe :human_attribute_name do
    it "translates attributes through FastGettext" do
      SimpleModel.should_receive(:s_).with('SimpleModel|Model attribute').and_return('The attribute name')
      SimpleModel.human_attribute_name(:model_attribute).should == 'The attribute name'
    end
  end

  describe :errors do
    let(:model){
      c = SimpleModel.new
      c.valid?
      c
    }

    it "translates error messages on attributes" do
      FastGettext.stub!(:current_repository).and_return('translate me'=>"Übersetz mich!")
      FastGettext._('translate me').should == "Übersetz mich!"
      model.errors[:model_attribute].first.should == "Übersetz mich!"
    end

    it "translates errors full messages" do
      FastGettext.stub!(:current_repository).and_return('translate me'=>"Übersetz mich!")
      FastGettext._('translate me').should == "Übersetz mich!"
      model.errors.full_messages.first.should == "Model attribute Übersetz mich!"
    end

    it "translates error messages with %{fn}" do
      pending
      FastGettext.stub!(:current_repository).and_return('translate me'=>"Übersetz %{fn} mich!")
      FastGettext._('translate me').should == "Übersetz %{fn} mich!"
      model.errors[:model_attribute].first.should == "Übersetz car_seat mich!"
    end
  end
end
