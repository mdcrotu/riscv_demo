##################
# DVT Tool Setup
##################

# DVT Eclipse path and version
DVT_VERSION ?= 25.1.12-e424
DVT_HOME    ?= $(HOME)/Tools/dvt_eclipse/$(DVT_VERSION)

DVT_CFG_DIR := $(PRJ_ROOT)/cfg/dvt
DVT_PROJECT ?= $(shell basename $(PRJ_ROOT))

# Test if a license is already set
DVT_LICENSE_FILE ?=
DVTLMD_LICENSE_FILE ?=
LM_LICENSE_FILE ?=
ifeq ($(strip $(DVTLMD_LICENSE_FILE)),)
  ifeq ($(strip $(LM_LICENSE_FILE)),)
    ifeq ($(strip $(DVT_LICENSE_FILE)),)
      DVTLMD_LICENSE_FILE := 20000@exercise
    else ifeq ($(strip $(DVT_LICENSE_FILE)),FLEXLM)
      DVTLMD_LICENSE_FILE := 20000@exercise
    endif
  endif
endif

export DVT_COMMON_SETTINGS=$(DVT_CFG_DIR)/common_settings
export DVT_LICENSE_DISABLE_EXPIRE_POPUP_MESSAGE
export GTK_OVERLAY_SCROLLING=0
export DVT_ENABLE_SV_INTERP_DEBUG=true

EXTRACTED_DVT_VERSION := $(notdir $(DVT_HOME))
#$(info EXTRACTED_DVT_VERSION    => $(EXTRACTED_DVT_VERSION))
ifneq ($(DVT_VERSION),$(EXTRACTED_DVT_VERSION))
    DVT_VERSION := $(EXTRACTED_DVT_VERSION)
endif

#########################################
# Eclipse Cache and Workspace Locations #
#########################################
DVT_ECLIPSESPACE := /tmp/$(USER)/dvt_eclipsespace-$(DVT_VERSION)
DVT_WORKSPACE    := /tmp/$(USER)/$(PWD)/dvt_workspace
DVT_PROJECT_HOME := $(shell readlink -f $(PRJ_ROOT))
DVT_CLI          := $(DVT_HOME)/bin/dvt_cli.sh -workspace $(DVT_WORKSPACE)

###########################################################################################
# Check if project is read-only and then redirect createProject to /tmp/$USER/dvt_project #
###########################################################################################
is_project_readonly := $(shell test -w $(DVT_PROJECT_HOME); echo $$?)
ifeq ($(is_project_readonly),1)
    ORIGINAL_DVT_PROJECT_HOME := $(DVT_PROJECT_HOME)
    DVT_PROJECT_HOME          := /tmp/$(USER)/dvt_project/$(ORIGINAL_DVT_PROJECT_HOME)
    $(info DVT_PROJECT_HOME is read-only. Relocating createProject:)
    $(info ORIGINAL_DVT_PROJECT_HOME => $(ORIGINAL_DVT_PROJECT_HOME))
    $(info DVT_PROJECT_HOME          => $(DVT_PROJECT_HOME))
endif

# Check if EXCLUDE is set in the PRJ_ROOT/Makefile 
ifeq ($(EXCLUDE),true)
    EXCLUDE_PATHS := -exclude projectRelativePath=.git
endif


#############################
# DVT Build Config XML File #
#############################
define BUILD_CONFIG_XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<build-config version="2">
    <current-build-name>$(DVT_PROJECT)</current-build-name>
</build-config>
endef
export BUILD_CONFIG_XML


####################################
# Target: tool & project info      #
####################################
dvt-info:
	@echo "-------------------------------------------------"
	@echo " DVT Tool Info:"
	@echo "-------------------------------------------------"
	@echo "  DVT_PROJECT:         $(DVT_PROJECT)"
	@echo "  DVT_PROJECT_HOME:    $(DVT_PROJECT_HOME)"
	@echo "  DVT_WORKSPACE:       $(DVT_WORKSPACE)"
	@echo "  DVT_ECLIPSESPACE:    $(DVT_ECLIPSESPACE)"
	@echo "  DVT VERSION:         $(DVT_VERSION)"
	@echo "  DVT HOME:            $(DVT_HOME)"
	@echo "  DVT_LICENSE_FILE:    $(DVT_LICENSE_FILE)"
	@echo "  DVTLMD_LICENSE_FILE: $(DVTLMD_LICENSE_FILE)"


################################################
# DVT Target: start DVT and create the project #
################################################
#dvt : clean-dvt check-project-ro dvt-gen buildxml waivers info
dvt : clean-dvt dvt-gen info
	$(TMI)$(DVT_HOME)/bin/dvt_cli.sh \
		-workspace $(DVT_WORKSPACE) \
		-eclipsespace $(DVT_ECLIPSESPACE) \
		createProject $(DVT_PROJECT_HOME) \
		$(DVT_PROJECT_LANG) \
		-heap_size $(HEAPSIZE) \
		$(MAP_LINKS) \
        $(EXCLUDE_PATHS) \
        -force

#        -disable_fs_check
#        -force -options disable_swt_auto_config

code: clean-dvt dvt-gen info
	code

###########################################################################
# If project is read-only, create a /tmp directory and symlink to project #
###########################################################################
check-project-ro:
	if [ $$is_project_readonly -eq 1 ] ; then \
	$(MKDIR) -p $(DVT_PROJECT_HOME); \
	cd $(DVT_PROJECT_HOME); \
	$(LN) -s $(ORIGINAL_DVT_PROJECT_HOME) `basename $(ORIGINAL_DVT_PROJECT_HOME)`; \
	fi;


#################################################
# DVT Target: start DVT with existing workspace #
#################################################
ws :
	$(TMI)@echo "DVT PATH: $(DVT_HOME)"
	$(TMI)$(DVT_HOME)/bin/dvt.sh \
		-workspace $(DVT_WORKSPACE) \
		-eclipsespace $(DVT_ECLIPSESPACE) \
		-heap_size $(HEAPSIZE)


##############################################
# DVT Target: generate project build files   #
##############################################
refresh : dvt-gen
	$(TMI)$(DVT_HOME)/bin/dvt_cli.sh \
		-workspace $(DVT_WORKSPACE) \
		-eclipsespace $(DVT_ECLIPSESPACE) \
		refreshProject $(notdir $(DVT_PROJECT_HOME))


##############################################
# DVT Target: generate project build files   #
##############################################
#dvt-gen : dotf-gen
#dvt-gen:
#	${MKDIR} -p ${PRJ_ROOT}/.dvt
#	@echo "$$MODEL_BUILD" > ${PRJ_ROOT}/.dvt/default.build
#	@echo "$$RUNCMD_BUILD" > ${PRJ_ROOT}/.dvt/run.cmd

# FIXME: Fix or delete this
##############################################
# cxl2idi_vlogan_opts.f file generation      #
##############################################
#dotf-gen :
#	if [ $$is_project_readonly -eq 0 ] ; then \
#	$(MAKE) -f Makefile.vcs.mk dotf-gen; \
#	fi;

##############################################
# DVT Target: create build.config.xml        #
##############################################
buildxml:
	$(TMI)@echo "$$BUILD_CONFIG_XML" > $(DVT_PROJECT_HOME)/.dvt/build.config.xml

##############################################
# DVT Target: copy waivers.xml to .dvt/      #
##############################################
waivers:
	$(TMI)[ -f $(DVT_CFG_DIR)/waivers.xml ] && $(LN) -s $(DVT_CFG_DIR)/waivers.xml $(DVT_PROJECT_HOME)/.dvt/waivers.xml || true
	$(TMI)[ -f $(DVT_CFG_DIR)/specador/specador_preferences.xml ] && $(LN) -s $(DVT_CFG_DIR)/specador/specador_preferences.xml $(DVT_PROJECT_HOME)/.dvt/specador_preferences.xml || true
	$(TMI)[ -f $(DVT_CFG_DIR)/verissimo/verissimo_waivers.xml ] && $(LN) -s $(DVT_CFG_DIR)/verissimo/verissimo_waivers.xml $(DVT_PROJECT_HOME)/.dvt/verissimo_waivers.xml || true

#############################################################
# DVT Eclipse Batch Build
#############################################################
batch-dvt: dvt-gen
	$(MKDIR) -p $(PRJ_ROOT)/output
	$(TMI)$(DVT_HOME)/bin/dvt_build.sh \
		-cmd  $(PRJ_ROOT)/.dvt/demo_model.build \
		-log  $(PRJ_ROOT)/output/demo_model.dvt_build.log \
		-compile_waivers $(DVT_CFG_DIR)/waivers.xml \
		$(DVT_PROJECT_LANG) \
		-heap_size $(HEAPSIZE)

#############################################################
# DVT Batch RA
#############################################################
dvt-ra: dvt-gen
	$(TMI)$(DVT_HOME)/bin/dvt_build.sh \
		-cmd  $(PRJ_ROOT)/.dvt/default.build \
		-run_cmd  $(PRJ_ROOT)/.dvt/run.cmd \
		$(DVT_PROJECT_LANG) \
		-heap_size $(HEAPSIZE) \
		-ra

#	$(MKDIR) -p $(PRJ_ROOT)/output
#		-compile_waivers $(DVT_CFG_DIR)/waivers.xml \
#		-log  $(PRJ_ROOT)/output/demo_model.dvt_build.log \

###################################################
# Target: Run Verissimo TB Linter                 #
###################################################
verissimo: clean-build dvt-gen waivers
	$(TMI)$(DVT_HOME)/bin/verissimo.sh \
	-ruleset $(DVT_CFG_DIR)/verissimo/verissimo_basic_ruleset.xml \
	-cmd $(DVT_PROJECT_HOME)/.dvt/demo_model.build \
	-compile_waivers $(DVT_CFG_DIR)/waivers.xml \
	-waivers $(DVT_CFG_DIR)/verissimo/verissimo_waivers.xml \
	-heap_size $(HEAPSIZE) \
	-log $(DVT_PROJECT_HOME)/verissimo.log \
	-gen_txt_report \
	-gen_html_report \
	-html_report_location $(DVT_PROJECT_HOME)/verissimo_html_report \
	-ignore_build_config_errors \
	-ignore_compile_errors \
	-license_queue_timeout 15

###################################################
# Target: Generate Specador documentation         #
###################################################
specador: clean-build clean-specador dvt-gen waivers
	$(TMI)$(DVT_HOME)/bin/specador.sh \
	-cmd $(DVT_PROJECT_HOME)/.dvt/demo_model.build \
	-preferences $(DVT_CFG_DIR)/specador/specador_preferences.xml \
	-menu $(DVT_CFG_DIR)/specador/specador_menu.xml \
	-compile_waivers $(DVT_CFG_DIR)/waivers.xml \
	-heap_size $(HEAPSIZE) \
	-lang vlog \
	-log $(DVT_PROJECT_HOME)/specador.log \
	-ignore_build_config_errors \
	-ignore_compile_errors \
	-license_queue_timeout 30

#	$(COPY) -f $(DVT_CFG_DIR)/specador/custom.js $(DVT_PROJECT_HOME)/SpecadorDocs/specador_html_doc/js/custom.js

##########################################################
# Clean Targets: remove the workspace and .project files #
##########################################################
clean-build:
	$(TMI)$(RM) -rf .dvt/*.build

clean-dvt:
	$(TMI)$(RM) -rf $(DVT_WORKSPACE)
	$(TMI)$(RM) -rf $(DVT_PROJECT_HOME)/.dvt/
	$(TMI)$(RM) -rf $(DVT_PROJECT_HOME)/.settings/
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/.cproject
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/.project
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/.pydevproject
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/dvt_build.log
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/dvt_run_all.log
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/dvt_uvm_runtime_elaboration.log
	if [ $$is_project_readonly -eq 1 ] ; then \
	$(RM) -f $(DVT_PROJECT_HOME)/`basename $(ORIGINAL_DVT_PROJECT_HOME)` ; \
	fi;

clean-specador:
	$(TMI)$(RM) -f doxygen.log
	$(TMI)$(RM) -f specador.log
	$(TMI)$(RM) -rf SpecadorDocs

clean-verissimo:
	$(TMI)$(RM) -f verissimo_uvm.log
	$(TMI)$(RM) -rf verissimo_uvm_html_report
	$(TMI)$(RM) -rf verissimo_custom_report

debug-sc:
	$(DVT_CLI) refreshProject $(DVT_PROJECT)
	$(DVT_CLI) launchRunConfig -name SystemC -debug
