# ============================================================================
#  Copyright (c) 2021.  Danilo Ramos
#  All rights reserved.
#  This license message must appear in all versions of this code including
#  modified versions.
#  Licensed under the BSD 3-Clause license.
# ============================================================================

TOPLEVEL_LANG ?= verilog
TOPLEVEL = eidma_intel_top
MODULE ?= test_eidma_intel_top_cq_cc_sanity
SIM ?= verilator
WAVES ?= 0

# -----------------------------------------------------------------------
# Common sim parameters
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 100ps
$(info simulation time(unit/precision): $(COCOTB_HDL_TIMEUNIT)/$(COCOTB_HDL_TIMEPRECISION) )
export COCOTB_RESOLVE_X ?= RANDOM
$(info RESOLVE_X set to $(COCOTB_RESOLVE_X))

# -----------------------------------------------------------------------
FILES := $(shell cat rtlfiles.lst)
VERILOG_SOURCES := $(FILES)
$(info Verilog files: )
$(info $(VERILOG_SOURCES) )

# -----------------------------------------------------------------------
# top-lvl parameters
export HW_PARAM_IBITS ?= 256
export HW_PARAM_DATA_BYTES ?= 32
export HW_PARAM_ADDR_WIDTH ?= 48
export HW_PARAM_ID_WIDTH ?= 2
export HW_PARAM_MAX_OUT ?= 30
export HW_PARAM_NVME_WIDTH ?= 16
# export HW_PARAM_HWVER ?= 16'h0000
export HW_PARAM_BURST_SIZE ?= 16
export HW_PARAM_RAM_DRIVE_PRESENT ?= 0
export HW_PARAM_CMB_BITS ?= 29
# export HW_PARAM_DDR_ADDR ?= 64'h2_0000_0000

# -----------------------------------------------------------------------
# --------------------------------------
# - Verilator -
ifeq ($(SIM), verilator)
    $(info ------------------)
    $(info CoCoTB + Verilator)
    COMPILE_ARGS += -I../../../rtl
    # Supress common anoying verilator warnings (unnecessary here for sim, not linting)
    EXTRA_ARGS += -Wno-fatal -Wno-UNOPT -Wno-UNOPTFLAT -Wno-UNUSED -Wno-WIDTH
    # --------------------------------------
    # top-lvl parameters
    EXTRA_ARGS += -GIBITS=$(HW_PARAM_IBITS)
    EXTRA_ARGS += -GDATA_BYTES=$(HW_PARAM_DATA_BYTES)
    EXTRA_ARGS += -GADDR_WIDTH=$(HW_PARAM_ADDR_WIDTH)
    EXTRA_ARGS += -GID_WIDTH=$(HW_PARAM_ID_WIDTH)
    EXTRA_ARGS += -GMAX_OUT=$(HW_PARAM_MAX_OUT)
    EXTRA_ARGS += -GNVME_WIDTH=$(HW_PARAM_NVME_WIDTH)
    # EXTRA_ARGS += -GHWVER=$(HW_PARAM_HWVER)
    EXTRA_ARGS += -GBURST_SIZE=$(HW_PARAM_BURST_SIZE)
    EXTRA_ARGS += -GRAM_DRIVE_PRESENT=$(HW_PARAM_RAM_DRIVE_PRESENT)
    EXTRA_ARGS += -GCMB_BITS=$(HW_PARAM_CMB_BITS)
    # EXTRA_ARGS += -GDDR_ADDR=$(HW_PARAM_DDR_ADDR)
    
    # --------------------------------------
    # wave | coverage
    ifeq ($(WAVE), 1)
        $(info + wave (fst))
        EXTRA_ARGS += --trace-fst --trace-structs
    endif
    ifeq ($(COVERAGE), 1)
        $(info + coverage)
        EXTRA_ARGS += --coverage
    endif
    $(info ------------------)
endif

# --------------------------------------
ifeq ($(SIM), modelsim)
    $(info ------------------)
    $(info CoCoTB + Modelsim)
    COMPILE_ARGS += +incdir+../../../rtl
    # top-lvl parameters
    SIM_ARGS += -G$(TOPLEVEL).DATA_BYTES=$(HW_PARAM_DATA_BYTES)
    # EXTRA_ARGS += -G$(TOPLEVEL).CQ_USER_WIDTH=$(HW_PARAM_CQ_USER_WIDTH)
    # EXTRA_ARGS += -G$(TOPLEVEL).CC_USER_WIDTH=$(HW_PARAM_CC_USER_WIDTH)
    SIM_ARGS += -G$(TOPLEVEL).ADDR_WIDTH=$(HW_PARAM_ADDR_WIDTH)
    SIM_ARGS += -G$(TOPLEVEL).ID_WIDTH=$(HW_PARAM_ID_WIDTH)
    SIM_ARGS += -G$(TOPLEVEL).MAX_OUT=$(HW_PARAM_MAX_OUT)
endif

# --------------------------------------
# - Icarus -
ifeq ($(SIM), icarus)
    $(info ------------------)
    $(info CoCoTB + Icarus)
    # --------------------------------------
    COMPILE_ARGS += -I../../../rtl
    # top-lvl parameters
    COMPILE_ARGS += -P $(TOPLEVEL).IBITS=$(HW_PARAM_IBITS)
    COMPILE_ARGS += -P $(TOPLEVEL).DATA_BYTES=$(HW_PARAM_DATA_BYTES)
    COMPILE_ARGS += -P $(TOPLEVEL).ADDR_WIDTH=$(HW_PARAM_ADDR_WIDTH)
    COMPILE_ARGS += -P $(TOPLEVEL).ID_WIDTH=$(HW_PARAM_ID_WIDTH)
    COMPILE_ARGS += -P $(TOPLEVEL).MAX_OUT=$(HW_PARAM_MAX_OUT)
    COMPILE_ARGS += -P $(TOPLEVEL).NVME_WIDTH=$(HW_PARAM_NVME_WIDTH)
    # COMPILE_ARGS += -P $(TOPLEVEL).HWVER=$(HW_PARAM_HWVER)
    COMPILE_ARGS += -P $(TOPLEVEL).BURST_SIZE=$(HW_PARAM_BURST_SIZE)
    COMPILE_ARGS += -P $(TOPLEVEL).RAM_DRIVE_PRESENT=$(HW_PARAM_RAM_DRIVE_PRESENT)
    COMPILE_ARGS += -P $(TOPLEVEL).CMB_BITS=$(HW_PARAM_CMB_BITS)
    # COMPILE_ARGS += -P $(TOPLEVEL).DDR_ADDR=$(HW_PARAM_DDR_ADDR)
    # --------------------------------------
    # wave
    ifeq ($(WAVE), 1)
        $(info + wave (fst))
        PLUSARGS += -fst
        ICARUS_WAVE = icarus_wave.v
        VERILOG_SOURCES += $(ICARUS_WAVE)
        COMPILE_ARGS += -s icarus_wave
        # --------------------------------------
        # generate Icarus wave module
        # from CoCoTB
        $(file >  $(ICARUS_WAVE), module icarus_wave();)
        $(file >> $(ICARUS_WAVE), initial begin)
        $(file >> $(ICARUS_WAVE),     $$dumpfile("wave.fst");)
        $(file >> $(ICARUS_WAVE),     $$dumpvars(0, $(TOPLEVEL));)
        $(file >> $(ICARUS_WAVE),     #1;)
        $(file >> $(ICARUS_WAVE), end)
        $(file >> $(ICARUS_WAVE), endmodule)
    endif
    $(info ------------------)
endif

# --------------------------------------------------------------
$(info Starting CoCoTB... )
include $(shell cocotb-config --makefiles)/Makefile.sim

# -----------------------------------------------------------------------
# --------------------------------------------------------------
# Icarus (waveforms):
# from CoCoTB
icarus_wave.v:
	echo 'module icarus_wave();' > $@
	echo 'initial begin' >> $@
	echo '  $$dumpfile("$(TOPLEVEL).lxt2");' >> $@
	echo '  $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo '  #1;' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	rm -fr __pycache__ sim_build
	rm -rf iverilog_dump.v
	rm -rf dump.fst $(TOPLEVEL).fst