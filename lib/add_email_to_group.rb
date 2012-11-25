#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'trollop'

load File.expand_path('/opt/aws/aws.config')

sns = AWS::SNS.new

opts = Trollop::options do
  opt :email, "Email Address", :short => "e", :type => String
  opt :snsarn, "Arn for SNS topic", :short => "a", :type => String
end

topic = sns.topics["#{opts[:snsarn]}"]
topic.subscribe("#{opts[:email]}")