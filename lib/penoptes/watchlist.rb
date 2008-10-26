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

require 'yaml'
require 'find'
require 'fileutils'

# our user defined String methods
class String
  def is_true?
    self[/^(1|on|yes|true|enabled)$/]
  end
  def is_false?
    self[/^(0|off|no|false|disabled)$/]
  end
end

module Penoptes
  class WatchlistError < SyntaxError; end

  class Watchlist
    def initialize(watchlist)
      if watchlist.nil? or not File.exists? watchlist
        raise LoadError, "#{watchlist}: No such file or directory."
      end
#    begin 
        @entries = parse YAML::load_file(watchlist)
#    rescue ArgumentError
#      raise WatchlistError, $!
#    end
    end

    def parse(yaml)
      entries = Array.new

      yaml.each do |entry|
        pathspec = entry.first
        options = entry.last

        # globbing or recursive?
        mode = 'globbing'
        if FileTest.directory?(pathspec) and not options.has_key?('recursive')
          mode = 'recursive'
        end
        if options.has_key?('recursive') and options['recursive'].is_false?
          mode = 'globbing'
        end

        # we do a find on entry.first
        if mode.eql? 'recursive'
          Find.find(pathspec) do |path|
            if FileTest.directory?(path)
              if File.basename(path)[0] == ?.
                Find.prune
              else
                next
              end
            else
              entries.push path if FileTest.file? path
            end
          end

        # entry has to be expanded with globbing (no recursion)
        else
          entries.push Dir.glob(pathspec)
        end
      end
      puts entries
    end

    def iterate &block
    end
  end
end

# EOF
