#####################################################################################
#  File: uart_tx_rx_tb.py
#  Copyright (c) 2021 Danilo Ramos
#  All rights reserved.
#  This license message must appear in all versions of this code including
#  modified versions.
#  BSD 3-Clause
####################################################################################
#  Overview:
"""
Simple UART Testbench - CoCoTB module
"""

# -----------------------------------------------------------------------------
# Info
__author__ = 'Danilo Ramos'
__copyright__ = 'Copyright (c) 2021'
__credits__ = ['Danilo Ramos']
__license__ = 'BSD 3-Clause'
__version__ = "0.0.1"
__maintainer__ = 'Danilo Ramos'
__email__ = 'dramoz@gmail.com'

# __status__ = ["Prototype"|"Development"|"Production"]
__status__ = "Prototype"

import sys, os
import logging
from pathlib import Path

from math import ceil
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ReadWrite

# -----------------------------------------------------------------------------
# Internal modules
_workpath = Path(__file__).resolve().parent
sys.path.append(str(_workpath))

HDL_VERIF_SCRIPTS = os.environ.get('HDL_VERIF_SCRIPTS')
assert HDL_VERIF_SCRIPTS is not None, "HDL_VERIF_SCRIPTS env. var not found! (required for loading run_sim)"
_hdl_verif_path = Path(HDL_VERIF_SCRIPTS) / 'src/hdl_verif'
sys.path.append(str(_hdl_verif_path))
print(_hdl_verif_path)
from run_cocotb_sim import run_cocotb_sim

# -----------------------------------------------------------------------------
# Parameters
CLK_FREQUENCY = 48000000
CLK_PERIOD = ceil(1 / CLK_FREQUENCY * 1e9)
CLK_PERIOD += CLK_PERIOD % 2
CLK_PERIOD_UNITS = 'ns'
BAUD_RATE = 115200

parameters = {
    'CLK_FREQUENCY': 48000000,
    'BUTTON_LOGIC_LEVEL': 0,
    'SYS_RESET_LOGIC_LEVEL': 1,
    'SYS_RESET_LOGIC_DEBOUNCE_MS': 1,
    'BOOT_RESET_LOGIC_LEVEL': 0,
    'BOOT_LONG_PRESS_DURATION_MS': 2,
}

# -----------------------------------------------------------------------------
# CoCoTB Module
@cocotb.test()
async def usr_rst_test(dut):
    """ Run n clk cycles """
    # Set logger
    log = logging.getLogger("TB")
    loglevel = os.environ.get("LOGLEVEL", 'INFO')
    log.setLevel(loglevel)
    
    # Start test
    log.info('usr_rst Test')
    
    # Setup TB
    log.info(f'CLK: {CLK_PERIOD} {CLK_PERIOD_UNITS}')
    clock = Clock(dut.clk48, CLK_PERIOD, units=CLK_PERIOD_UNITS) 
    cocotb.fork(clock.start())
    dut.usr_btn <= 1
    await Timer(1, units='us')
    dut.usr_btn <= 0
    await Timer(800, units='us')
    dut.usr_btn <= 1
    await Timer(50, units='us')
    dut.usr_btn <= 0
    await Timer(1500, units='us')
    dut.usr_btn <= 1
    await Timer(50, units='us')
    dut.usr_btn <= 0
    await Timer(3, units='ms')
    dut.usr_btn <= 1
    log.info('Test done!')

# -----------------------------------------------------------------------------
# Invoke test
if __name__ == '__main__':
    run_cocotb_sim(
        py_module=Path(__file__).stem,
        workpath=Path(__file__).resolve().parent,
        test_name='usr_rst',
        top_level='usr_rst',
        include_dirs=['./'],
        hdl_sources=['./usr_rst.sv'],
        parameters=parameters,
        testcase=None
    )
    