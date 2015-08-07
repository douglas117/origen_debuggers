class Debuggers_Application
  # An instance of this class is pre-instantiated at: RGen.app.pdm_component
  class PDMComponent

    include RGen::PDM

    def initialize(options={})
      @pdm_use_test_system = true       # Set this to false to deploy to live PDM
      #@pdm_initial_version_number = 2  # Only set this if starting from an pre-existing component

      @pdm_part_name = "Debuggers"
      @pdm_part_type = "software"
      @pdm_vc_type = "generator"
      @pdm_functional_category = "software|unclassifiable"
      @pdm_version = RGen.app.version
      @pdm_support_analyst = "Stephen McGinty (r49409)"
      @pdm_security_owner = "Stephen McGinty (r49409)"
      @pdm_owner = "Stephen McGinty (r49409)"
      @pdm_design_manager = "Stephen McGinty (r49409)"
      @pdm_cm_version = RGen.app.version
      @pdm_cm_path = "sync://sync-15088:15088/Projects/common_tester_blocks/rgen_blocks/tester/Debuggers"
    end

  end
end
