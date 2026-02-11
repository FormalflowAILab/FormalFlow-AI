from cocotb import test
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@test()
async def test_counter_basic(dut):
    """Basic functional test: reset, run, and check counting behavior."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # apply reset
    dut.rst.value = 1
    await Timer(20, "ns")
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    seen15 = False
    prev = int(dut.count.value)

    # run for a number of cycles and check increment/wrap behavior
    for _ in range(40):
        await RisingEdge(dut.clk)
        cur = int(dut.count.value)
        assert 0 <= cur <= 15, f"count out of range: {cur}"
        if prev == 15:
            assert cur == 0, f"expected wrap to 0 after 15, got {cur}"
        else:
            assert cur == (prev + 1), f"expected {prev+1}, got {cur}"
        if cur == 15:
            seen15 = True
        prev = cur

    assert seen15, "Counter never reached 15 during the test"
