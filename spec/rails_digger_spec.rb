# frozen_string_literal: true

require "bundler/setup"
require "spec_helper"
require 'fileutils'

require "rails_digger"


RSpec.describe "RailsDigger" do
  let(:directory) { "spec/fixtures" }
  let(:analyzer) { RailsDigger::Analyzer.new(directory) }

  before do
    FileUtils.mkdir_p(directory)
    File.write("#{directory}/test_file.rb", <<~RUBY)
      def test_method
        puts 'Hello, world!'
      end
    RUBY
  end
  
  it "has a version number" do
    expect(RailsDigger::VERSION).not_to be nil
  end
  
  after do
    FileUtils.rm_rf(directory)
  end

  it "finds methods in Ruby files" do
    expect { analyzer.analyze }.to output(/Methods found: test_method/).to_stdout
  end
end
