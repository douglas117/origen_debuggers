class Debuggers_Application < RGen::Application

  # See http://rgen.freescale.net/rgen/latest/api/RGen/Application/Configuration.html
  # for a full list of the configuration options available

  # This information is used in headers and email templates, set it specific
  # to your application
  config.name     = "Debuggers"
  config.initials = "Debuggers"
  config.vault    = "sync://sync-15088:15088/Projects/common_tester_blocks/rgen_blocks/tester/Debuggers/tool_data/rgen" 

  # Force naming for gem
  self.name = "rgen_debuggers"
  self.namespace = "Debuggers"

  # To enable deployment of your documentation to a web server (via the 'rgen web'
  # command) fill in these attributes. The example here is configured to deploy to
  # the rgen.freescale.net domain, which is an easy option if you don't have another
  # server already in mind. To do this you will need an account on CDE and to be a member
  # of the 'rgen' group.
  config.web_directory = "/proj/.web_rgen/html/debuggers"
  config.web_domain = "http://rgen.freescale.net/debuggers"

  # When false RGen will be less strict about checking for some common coding errors,
  # it is recommended that you leave this to true for better feedback and easier debug.
  # This will be the default setting in RGen v3.
  config.strict_errors = true

  config.semantically_version = true

  # By default all generated output will end up in ./output.
  # Here you can specify an alternative directory entirely, or make it dynamic such that
  # the output ends up in a setup specific directory. 
  #config.output_directory do
  #  "#{RGen.root}/output/#{$dut.class}"
  #end

  # Similary for the reference files, generally you want to setup the reference directory
  # structure to mirror that of your output directory structure.
  #config.reference_directory do
  #  "#{RGen.root}/.ref/#{$dut.class}"
  #end
  
  # Ensure that all tests pass before allowing a release to continue
  def validate_release
    if !system("rgen examples")
      puts "Sorry but you can't release with failing tests, please fix them and try again."
      exit 1
    else
      puts "All tests passing, proceeding with release process!"
    end
  end

  # Run the tests before deploying to generate test coverage numbers
  def before_deploy_site
    Dir.chdir RGen.root do
      system "rgen examples -c"
      #system "rgen specs -c"
      dir = "#{RGen.root}/web/output/coverage"       
      FileUtils.remove_dir(dir, true) if File.exists?(dir) 
      system "mv #{RGen.root}/coverage #{dir}"
    end
  end
 
  # This will automatically deploy your documentation after every tag
  def after_release_email(tag, note, type, selector, options)
    deployer = RGen.app.deployer
    if deployer.running_on_cde? && deployer.user_belongs_to_rgen?
      command = "rgen web compile --remote --api"
      if RGen.app.version.production?
        command += " --archive #{RGen.app.version}"
      end
      Dir.chdir RGen.root do
        system command
      end
    end 
  end

end
