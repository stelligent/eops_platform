#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'trollop'

load File.expand_path('/opt/aws/aws.config')

opts = Trollop::options do
  opt :domain, "Name of Domain", :short => "d", :type => String
end

sdb = AWS::SimpleDB.new

domain = sdb.domains["stacks"]
domain.items["#{opts[:domain]}"].delete
