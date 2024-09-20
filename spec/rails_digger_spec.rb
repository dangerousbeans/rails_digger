# frozen_string_literal: true

require "bundler/setup"
require_relative "spec_helper"
require 'fileutils'
require "rails_digger"

RSpec.describe "RailsDigger" do
  let(:directory) { "spec/fixtures" }
  let(:analyzer) { RailsDigger::Analyzer.new(directory) }

  before do
    FileUtils.mkdir_p(directory)
    
    # Create a Ruby file with various method definitions
    File.write("#{directory}/test_file.rb", <<~RUBY)
      def test_method
        puts 'Hello, world!'
      end

      def self.class_method
        puts 'Class method!'
      end

      define_method(:dynamic_method) do
        puts 'Dynamic method!'
      end
    RUBY

    # Create an ERB template file
    File.write("#{directory}/test_template.html.erb", <<~ERB)
      <%= test_method %>
    ERB

    # Create a routes file
    File.write("#{directory}/config/routes.rb", <<~RUBY)
      Rails.application.routes.draw do
        get 'home#index'
        post 'users#create'
      end
    RUBY
  end
  
  after do
    FileUtils.rm_rf(directory)
  end

  it "has a version number" do
    expect(RailsDigger::VERSION).not_to be nil
  end

  it "finds instance methods in Ruby files" do
    expect { analyzer.analyze }.to output(/Methods found: test_method/).to_stdout
  end

  it "finds class methods in Ruby files" do
    expect { analyzer.analyze }.to output(/Methods found: class_method/).to_stdout
  end

  it "finds dynamic methods in Ruby files" do
    expect { analyzer.analyze }.to output(/Methods found: dynamic_method/).to_stdout
  end

  it "finds methods in templates" do
    expect { analyzer.analyze }.to output(/Methods found in template: test_method/).to_stdout
  end

  it "finds methods expected from routes" do
    expect { analyzer.analyze }.to output(/Methods expected from routes: index, create/).to_stdout
  end
end