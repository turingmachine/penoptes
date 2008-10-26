#!/usr/bin/env ruby

# penoptes - monitor text file for changes
#
# Copyright (C) 2008  Simon Josi <josi@puzzle.ch>
#
# This program is free software: you can redistribute it and/or 
# modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation, either version 3 
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 'ostruct'
require 'optparse'
require 'penoptes/configuration'
require 'penoptes/watchlist'
require 'penoptes/repository'
require 'penoptes/report'

module Penoptes
  class << self
    def application
      @application ||= Penoptes::Application.new
    end
  end

  class Application
    def initialize
      register_signal_handlers
      
      @options = parse_options
      begin
        @configuration = \
        Penoptes::Configuration.new
      rescue LoadError
        puts 'penoptes: could not load configuration', $!
        terminate 1
      end

      @watchlist = Penoptes::Watchlist.new @configuration.watchlist
      @repository = Penoptes::Repository.new
      @report = Penoptes::Report.new
    end

    def run
      
    end

    # register signal handlers
    def register_signal_handlers
      %w{ INT KILL QUIT TERM }.each do |signal|
        trap(signal) { terminate }
      end
    end

    # terminate programm sanely
    def terminate(exit_status = 0)
      exit exit_status
    end

    # evaluate cli switches
    def parse_options
      options = OpenStruct.new
      scriptname = File.basename($0)
      begin
        OptionParser.new do |opts|
          opts.banner = "Usage: #{scriptname} [options]"

          opts.on("-v", "--verbose", "show whats going on") do |o|
            options.verbose = true
          end

          opts.on("-c", "--configuration FILE", 
                  "use configuration file other than /etc/penoptes.yml") do |o|
            options.configuration = o
          end

          opts.on("-w", "--watchlist FILE", "use this watchlist") do |o|
            options.watchlist = o
          end

          opts.on("-f", "--fast", "don't slow down I/O") do |o|
            options.fast = true
          end

          opts.on("-p", "--print", "print expanded watchlist and exit") do |o|
            options.print = true
          end

          opts.on("-h", "--help",  "display this help and exit") do |o|
            puts opts.banner
            puts "Options:"
            puts opts.summarize
            terminate
          end
        end.parse!
      rescue
        puts "#{scriptname}: " + $!
        puts "Try \`#{scriptname} --help' for more information."
        terminate 1
      end

      return options
    end
  end
end

# EOF
