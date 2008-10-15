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

require 'optparse'

class Penoptes
  def initialize
    register_signal_handlers
    evaluate_cli_switches
    load_resources
    configuration = Configuraton.new
    repository = Repository.new
  end


private

  # register signal handlers
  def register_signal_handlers
    %w{ INT KILL QUIT TERM }.each do |signal|
      trap(signal) { terminate }
    end
  end

  # terminate programm sanely
  def terminate(exit_code = 0)
    exit exit_status
  end

  # evaluate cli switches
  def evaluate_cli_switches
    scriptname = File.basename($0)
    begin
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{scriptname} [options]"

        opts.on("-v", "--verbose", "show whats going on") do |d|
          @cli_switches['verbose'] = true
        end

        opts.on("-c", "--configuration", 
                "specify a configuration file other than /etc/penoptes.yml") do |s|
          @cli_switches['configuration'] = s
        end

        opts.on("-f", "--fast", "don't slow down io") do |s|
          @cli_switches['fast'] = true
        end

        opts.on("-h", "--help",  "display this help and exit") do |h|
          puts opts.banner
          puts "Options:"
          puts opts.summarize
          terminate
        end

        opts.parse!
      end
    rescue
      puts "#{scriptname}: " + $!
      puts "Try \`#{scriptname} --help' for more information."
      terminate 1
    end
  end
end

# EOF
