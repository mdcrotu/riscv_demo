
DVT_COMPATIBILITY_MODE := questa.vlog

#-----------------------------------
# Quartus/QuestaSim Tool Setup
#-----------------------------------
QUARTUS_VER  := 24.1std
QUARTUS_DISK := $(HOME)/Tools/intelFPGA_lite
QUARTUS_PATH := $(QUARTUS_DISK)/$(QUARTUS_VER)/quartus
QUESTA_PATH  := $(QUARTUS_DISK)/$(QUARTUS_VER)/questa_fse/
QUARTUS_HOME ?= $(QUARTUS_PATH)
QUESTA_HOME  ?= $(QUESTA_PATH)

PATH := $(QUARTUS_HOME)/bin:$(QUESTA_HOME)/bin:$(PATH)

# Test if a license is already set
ifeq ($(strip $(LM_LICENSE_FILE)),)
  LM_LICENSE_FILE := 21000@exercise
endif

####################################
# Display Questa Tool Info
####################################
questa-info:
	@echo "-------------------------------------------------"
	@echo " QuestaSim Info"
	@echo "-------------------------------------------------"
	@echo "  QUARTUS_VER:         $(QUARTUS_VER)"
	@echo "  QUARTUS_HOME:        $(QUARTUS_HOME)"
	@echo "  QUESTA_HOME:         $(QUESTA_HOME)"
	@echo "  LM_LICENSE_FILE:     $(LM_LICENSE_FILE)"
