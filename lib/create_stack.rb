#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'trollop'
load File.expand_path('/opt/aws/aws.config')

opts = Trollop::options do
  opt :stackname, "Name of stack", :short => "n", :type => String
  opt :templatelocation, "Path to CloudFormation Template", :short => "l",  :type => String
  opt :domain, "Route 53 Domain", :short => "d",  :type => String
  opt :application, "Name of application", :short => "a",  :type => String
  opt :sshkey, "SSH Key used in CloudFormation Template", :short => "k",  :type => String
  opt :securitygroup, "Name of security group used in CloudFormation Template", :short => "g",  :type => String
  opt :snstopic, "Simple Notification Topic used in CloudFormation Template", :short => "s",  :type => String
  opt :s3bucket, "S3 Bucket", :short => "b",  :type => String
  opt :scriptedorami, "SCRIPTED or AMI", :short => "m", :type => String
  opt :ami, "AMI to use", :short => "i", :type => String
  opt :group, "AMI to use", :short => "t", :type => String
end

file = File.open("#{opts[:templatelocation]}", "r")
template = file.read

cfn = AWS::CloudFormation.new
stack = cfn.stacks.create(
        "#{opts[:stackname]}", 
        template,
        :parameters => {
          "Group" => "#{opts[:group]}",
          "UseScriptedOrAMI" => "#{opts[:scriptedorami]}",
          "AMI" => "#{opts[:ami]}",
          "HostedZone" => "#{opts[:domain]}",
          "ApplicationName" => "#{opts[:application]}",
          "KeyName" => "#{opts[:sshkey]}",
          "SGID" => "#{opts[:securitygroup]}",
          "S3Bucket" => "#{opts[:s3bucket]}",
          "SNSTopic" => "#{opts[:snstopic]}"
        },
        :capabilities => ["CAPABILITY_IAM"]
        )
        
while stack.status != "CREATE_COMPLETE"
  sleep 30
  
  case stack.status
  when "ROLLBACK_IN_PROGESS"
    stack.delete
  when "ROLLBACK_COMPLETE"
    stack.delete
  end
end

stack = cfn.stacks["#{opts[:stackname]}"]
File.open("/tmp/#{opts[:stackname]}", "w") do |aFile|
   stack.outputs.each do |output|
     cfnOutput = output.key + "=" + output.value + "\n"
     aFile.syswrite(cfnOutput) 
   end
end