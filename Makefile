
PRJ_ROOT  := $(CURDIR)
REPO_ROOT := $(PRJ_ROOT)
$(info CURDIR    => $(CURDIR))
$(info PRJ_ROOT  => $(PRJ_ROOT))
$(info REPO_ROOT => $(REPO_ROOT))

.EXPORT_ALL_VARIABLES:
ifneq (,$(wildcard $(REPO_ROOT)/makefiles/Makefile.common.mk))
    include $(REPO_ROOT)/makefiles/Makefile.common.mk
endif

ifneq (,$(wildcard $(REPO_ROOT)/makefiles/Makefile.dvt.mk))
    include $(REPO_ROOT)/makefiles/Makefile.dvt.mk
endif

ifneq (,$(wildcard $(REPO_ROOT)/makefiles/Makefile.questa.mk))
    include $(REPO_ROOT)/makefiles/Makefile.questa.mk
endif

ifneq (,$(wildcard $(REPO_ROOT)/makefiles/Makefile.verilator.mk))
    include $(REPO_ROOT)/makefiles/Makefile.verilator.mk
endif

ifneq (,$(wildcard $(PRJ_ROOT)/Makefile.deps.mk))
    include $(PRJ_ROOT)/Makefile.deps.mk
endif

ifneq (,$(wildcard $(PRJ_ROOT)/Makefile.src.mk))
    include $(PRJ_ROOT)/Makefile.src.mk
endif

################
# DVT Settings
################
DVT_PROJECT_LANG := -lang vlog
#DVT_PROJECT_LANG += -lang cpp
EXCLUDE  ?= true
HEAPSIZE ?= 4G

MAP_LINKS :=
#MAP_LINKS += -map shared_makefiles $(REPO_ROOT)/makefiles


##############################################
# DVT Target: generate project build files
##############################################
#dvt-gen : dotf-gen
dvt-gen:
	${MKDIR} -p ${PRJ_ROOT}/.dvt
	@echo "$$MODEL_BUILD" > ${PRJ_ROOT}/.dvt/default.build
	@echo "$$RUNCMD_BUILD" > ${PRJ_ROOT}/.dvt/run.cmd


####################################
# Display Tool and Project Info
####################################
# FIXME: add a target to Makefile.questa.mk for questa-info
info: dep-info dvt-info questa-info
	@echo "-------------------------------------------------"
	@echo " GIT Project Info"
	@echo "-------------------------------------------------"
	@echo "  GIT_REPO_HOME:       $(REPO_ROOT)"
	@echo ""


#################
# Makefile Help #
#################
define HELP_USAGE
-------------------------------------------------------------------------------
 Makefile Help
-------------------------------------------------------------------------------
Usage:
    make <target> <PARAMETER>=<VALUE>

NOTE: make must be run in the directory where the Makefile resides

Parameters:
    EXCLUDE              Will exclude unused directories from the Eclipse Project View
                             true or false, default is false
    HEAPSIZE             Change the JVM Heap Size (default is 1G)

Example:
    make [help]            <-- displays help message
    make targets           <-- displays the available targets
    make dvt               <-- creates the build files and starts DVT Eclipse clean
    make info              <-- displays all tool versions
    make dvt_info          <-- displays only DVT tool version info
    make dvt HEAPSIZE=8G   <-- starts DVT Eclipse clean with a heap size of 8G
    make dvt EXCLUDE=true  <-- starts DVT Eclipse clean and enables exclude directories

endef
export HELP_USAGE

#################################
# Target: help & Makefile usage #
#################################
help:
	@echo "$$HELP_USAGE"

clean:
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/tr_db.log
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/*.wlf
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/*.vcd
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/qrun.log
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/transcript
	$(TMI)$(RM) -rf $(DVT_PROJECT_HOME)/qrun.out/
	$(TMI)$(RM) -rf $(DVT_PROJECT_HOME)/work/
	$(TMI)$(RM) -rf $(DVT_PROJECT_HOME)/obj_dir/
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/*.log
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/*.dmp
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/*.vpd
	$(TMI)$(RM) -f $(DVT_PROJECT_HOME)/core

clean-all: clean clean-dvt
