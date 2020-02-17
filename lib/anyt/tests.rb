# frozen_string_literal: true

require "anyt"
require "anyt/client"
require_relative "ext/minitest"

module Anyt
  # Loads and runs test cases
  module Tests
    class << self
      DEFAULT_PATTERNS = [
        File.expand_path("tests/**/*.rb", __dir__)
      ].freeze

      # Run all loaded tests
      def run
        Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

        AnyCable.logger.debug "Run tests against: #{Anyt.config.target_url}"
        Minitest.run
      end

      # Load tests code (filtered if present)
      #
      # NOTE: We should run this before launching RPC server

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def load_tests
        return load_all_tests unless Anyt.config.filter_tests?

        skipped = []
        filter = Anyt.config.tests_filter

        test_files_patterns.each do |pattern|
          Dir.glob(pattern).each do |file|
            if file.match?(filter)
              require file
            else
              skipped << file.gsub(File.join(__dir__, 'tests/'), '').gsub('_test.rb', '')
            end
          end
        end

        $stdout.print "Skipping tests: #{skipped.join(', ')}\n"
      end

      # Load all test files
      def load_all_tests
        test_files_patterns.each do |pattern|
          Dir.glob(pattern).each { |file| require file }
        end
      end

      private

      def test_files_patterns
        @test_files_patterns ||= DEFAULT_PATTERNS.dup.tap do |patterns|
          patterns << Anyt.config.tests_path if Anyt.config.tests_path
        end
      end
    end
  end
end