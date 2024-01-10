# Gigabit Transceiver
using gigabit transceiver phy of ultrascale+ FPGA to handle high speed data converter or FPGA to FPGA communication

The Aurora MAC project uses ultrascale + FPGA gigabit transceiver as PHY and Aurora IP from Xilinx as MAC to handle AXI4 bus data transfer. It allows Microblaze to transfer and receiver AXI4 data from other FPGA.
The Image Sensor project uses ultrascale + FPGA gigabit transeiver as PHY and use slvs-ec IP as MAC to handle the high speed digital imager interface. It takes the image data both to the async FIFO for FPGA fabric processing or to the DMA transfer using AXIS interface for embedded processor processing.