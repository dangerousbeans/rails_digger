# test_analyzer.rb

require_relative 'lib/rails_digger'

analyzer = RailsDigger::Analyzer.new('/home/joran/development/TRS/therugbysite')
analyzer.analyze

