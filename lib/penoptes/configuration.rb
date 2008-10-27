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
require 'socket'

module Penoptes
  class ConfigurationError < StandardError; end
  class Configuration

    # define default values for all configuration options
    DEFAULTS = {
      'id'                  => Socket.gethostname,
      'configuration'       => '/etc/penoptes.conf',
      'watchlist'           => '/etc/penoptes.watchlist',
      'state_directory'     => '/var/lib/penoptes',
      'remote_repository'   => 'off',
      'mail_from'           => 'root',
      'mail_to'             => 'root',
      'add_cycle'           => '1h',
      'change_cycle'        => '15m',
      'fast'                => 'off'
    }

    # metaclass access method
    def metaclass; class << self; self; end; end

    def initialize(options)
      # use cli supplied configuration file if available,
      # use default value otherwise
      if options.respond_to? 'configuration'
        configfile = options.configuration
      else
        configfile  = DEFAULTS['configuration']
      end

      # raise an error if configuration file does not exist
      unless File.exists? configfile
        raise ConfigurationError, "#{configfile}: No such file or directory."
      end

      # set an instance variable with additonal attr_reader 
      # for each default value except configuration
      DEFAULTS.each do |key, value|
        unless key.eql? 'configuration'
          instance_variable_set "@" + key, value
          metaclass.module_eval { attr_reader key }
        end
      end

      # parse configuration and overwrite each instance variable with 
      # corresponding value from configuration
      YAML::load_file(configfile).each do |key, value|
        if DEFAULTS.has_key? key
          instance_variable_set "@" + key, value
        end
      end

      # use cli supplied watchlist if available
      if options.respond_to? 'watchlist'
        @watchlist = options.watchlist 
      end
    end
  end
end

# EOF
