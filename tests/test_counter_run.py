from cocotb_test.simulator import run
import os


def test_counter_verilator():
    run(
        toplevel="counter",
        verilog_sources=[os.path.join("src","counter.sv")],
        module="test_counter",
        simulator="verilator",
    )
