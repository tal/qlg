require 'logger'

module Qlg
  VERSION = File.open(File.expand_path(File.join(File.dirname(__FILE__),'..','VERSION'))).read.freeze
  
  if File.directory?('log')
    LOGS = Hash.new {|h,k| h[k] = Logger.new("log/#{k}.log")}
  else
    LOGS = Hash.new {|h,k| h[k] = Logger.new("#{k}.log")}
  end
  
  extend self
  
  # Not sure how much faster this is than method missing
  def create_log name
    name = name.to_s
    
    Log.send :define_method, name do
      LOGS[name]
    end
    
    LOGS[name] # Initialize the log
  end
  
  def method_missing name
    LOGS[name]
  end
  
  DEFAULT_NAME = ENV['RACK_ENV']||ENV['RAILS_ENV']||ENV['MERB_ENV']||'default'
  DEFAULT = LOGS[DEFAULT_NAME]
  def default; DEFAULT; end
  %w{fatal error warn info debug}.each do |meth|
    class_eval <<-RB
      def #{meth} *args, &blk
        DEFAULT.#{meth}(*args,&blk)
      end
    RB
  end
end
