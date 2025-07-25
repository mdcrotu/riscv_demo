################################
# External Dependent Libraries
################################

#-------------------------------------
# UVM
#-------------------------------------
UVM_VERSION ?= 1.2
UVM_HOME    ?= $(HOME)/Tools/Accellera/UVM/uvm-$(UVM_VERSION)


################################
# GCC Setup
################################

TARGET_ARCH ?= linux64

GCC_PATH := /usr/bin
CPP      := $(GCC_PATH)/g++
CXX      := $(GCC_PATH)/g++
GCC      := $(GCC_PATH)/gcc


####################################
# Display Dependent Info
####################################
dep-info:
	@echo "-------------------------------------------------"
	@echo " Dependent Tool Info"
	@echo "-------------------------------------------------"
	@echo "  UVM_HOME:            $(UVM_HOME)"
	@echo "  TARGET_ARCH:         $(TARGET_ARCH)"
	@echo "  CPP:                 $(CPP)"

