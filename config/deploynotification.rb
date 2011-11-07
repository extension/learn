require 'rubygems'
require 'action_mailer'
require 'getoptlong'
require 'net/smtp'
require 'time'
require 'getoptlong'
require 'digest/md5'

### Program Options
progopts = GetoptLong.new(
  [ "--environment","-e", GetoptLong::OPTIONAL_ARGUMENT ],
  [ "--previous","-p", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--latest","-l", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--branch","-b", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--application","-a", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--user","-u", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--host","-h", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--release_path","-r", GetoptLong::REQUIRED_ARGUMENT ]
)

@gitcommand = '/usr/bin/git'
@environment = 'production'

progopts.each do |option, arg|
  case option
    when '--environment'
      @environment = arg
    when '--previous'
      @previous_release = arg
    when '--latest'
      @latest_release = arg
    when '--release_path'
      @release_path = arg
    when '--branch'
      @branch = arg
    when '--application'
      @application = arg
    when '--host'
      @host = arg
    when '--user'
      @user = arg
    else
      puts "Unrecognized option #{opt}"
      exit 0
    end
end
@mailFrom = "exdev@extension.org"
@mailTo = "dev-deploys@lists.extension.org"
@mailRelay = "sendmail.extension.org"

@app_releases_dir = "/services/apache/vhosts/#{@target}/docroot/releases"


def runcommand(command)
  outputString command,"\n" if @verbose
  cmdoutput =  %x{#{command}}
  outputString cmdoutput if @verbose
  return cmdoutput
end

### Classes

class DoMail < Net::SMTP
  def initialize(options)
      super
      @from     = options["from"]
      @to       = options["to"].split(",")
      @server   = options["server"]
      @subject  = options["subject"]
  end

  def body=(mailmessage)
      msgTime = Time.new.httpdate
      # BUILD HEADERS
      @body =  "From: #{@from} <#{@from}>\n"
      @to.each{|send_to| @body << "To: #{send_to}<#{send_to}>\n"}
      @body << "Subject: #{@subject}\n"
      @body << "Date: #{msgTime}\n"
      @body << "\n\n"
      # MESSAGE BODY
      @body << mailmessage
  end

  def send
    smtp = Net::SMTP.start(@server, 25)
    smtp.send_message  @body, @from, @to
    smtp.finish
  end
end



############ MAIN ##############

release_path = File.expand_path(File.dirname(__FILE__) + "/../")
command = "cd #{@release_path} && #{@gitcommand} log --shortstat --summary #{@previous_release}..#{@latest_release}"
@scm_output = runcommand(command)

if !@dryrun
  msgTime = Time.now
  mailmsg = <<ENDOFMESSAGE
===================================================
App:  #{@application} #{@branch} r#{@latest_release}
Date:  #{msgTime}
Deployed by:  #{@user}
Deployed to: #{@host}
===================================================


Commits related to this deploy:

#{@scm_output}

ENDOFMESSAGE

#mailmsg = mailmsg

mailoptions = {"from" => @mailFrom,"to" => @mailTo, "server" => @mailRelay,"subject" => "eXtension Initiative: #{@application} deployment notification" }
mailHandler = DoMail.new(mailoptions)
mailHandler.body=mailmsg
mailHandler.send()
end


