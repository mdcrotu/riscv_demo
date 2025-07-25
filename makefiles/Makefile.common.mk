#################
# Commands Used
#################
CAT    := /usr/bin/cat
MAKE   := /usr/bin/make
MKDIR  := /bin/mkdir
COPY   := /bin/cp
MV     := /bin/mv
RM     := /bin/rm
LN     := /bin/ln
GREP   := /bin/grep
FIND   := /bin/find
SED    := /bin/sed
DIFF   := /usr/bin/diff
TKDIFF := /usr/bin/tkdiff
MELD   := /usr/bin/meld

###############################################
# Variable to prevent compile command display #
###############################################
TMI ?= @

# Name of currently executed Makefile (used by the target)
MAKEFILE_NAME := $(word $(words $(MAKEFILE_LIST)),1st $(MAKEFILE_LIST))


#################################
# Useful Makefile debug target  #
#  Usage: make print-<variable> #
#################################
print-%  : ; @echo $* = $($*)

#################################
# Useful Makefile debug target  #
#  Usage: make showdef-<define> #
#################################
showdef-% : ; @echo "$$$*"

#####################################################
# Create a user preferred terminal
# User can set their terminal with:
# update-alternatives --config x-terminal-emulator
#####################################################
term : ; /usr/bin/x-terminal-emulator &

#################################
# Create a konsole
#################################
konsole : ; /usr/bin/konsole &

############################################
# Target: list all targets
# 1 grep for targets
# 2 strip dependent targets
# 3 insert 2 spaces before target name
# 4 print targets sorted alphabetically
############################################
targets:
	@echo -e "\nTARGETS:"
	@echo $(CURDIR)/$(MAKEFILE_NAME)
	@make -qpRr -f $(MAKEFILE_NAME) | egrep -e '^[a-z].*:.*$$' | sed -e 's/:.*//g' | sed -e 's/^/  /g' | sort
	@echo ""

