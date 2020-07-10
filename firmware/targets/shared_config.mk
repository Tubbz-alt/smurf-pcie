# Define Firmware Version: v2.3.0.1
export PRJ_VERSION = 0x02030001

# Define release
ifndef RELEASE
export RELEASE = all
endif

# Define target output
target: prom
