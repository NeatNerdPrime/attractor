# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    shared_options = [[:file_prefix, aliases: :p],
                      [:watch, aliases: :w, type: :boolean],
                      [:type, aliases: :t]]

    advanced_options = [[:format, aliases: :f, default: 'html'],
                        [:no_open_browser, type: :boolean],
                        [:ci, type: :boolean]]

    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    def calc
      file_prefix = options[:file_prefix]
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators).watch
      else
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators).report
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'report', 'Generates an HTML report'
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def report
      file_prefix = options[:file_prefix]
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      open_browser = !(options[:no_open_browser] || options[:ci]) 
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).watch
      else
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).report
        else
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).report
        end
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'serve', 'Serves the report on localhost'
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def serve
      file_prefix = options[:file_prefix]
      open_browser = !(options[:no_open_browser] || options[:ci]) 
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).watch
      else
        case options[:format]
        when 'html'
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).report
        else
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators, open_browser: open_browser).report
        end
      end
    end
  end
end
