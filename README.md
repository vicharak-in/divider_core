# Divider Application Design using Verilog on FPGA with RAH

## Introduction to Divider
A divider circuit is a fundamental component used to perform division operations in digital circuits. This project implements a hardware-based division operation using Verilog on an FPGA. The design includes support for both **signed** and **unsigned** inputs, making it versatile for various computational applications. Additionally, it is implemented with **pipeline stages**, ensuring efficient execution of division operations.

This project serves as an application example using the **Real-time Application Handler (RAH)** protocol, which enables seamless communication between the CPU and FPGA.

## Understanding RAH (Real-time Application Handler)
RAH is a protocol developed by Vicharak to facilitate efficient data transfer between the CPU and FPGA. It enables the CPU to run multiple applications, encapsulating their data into structured frames identified by an **app_id** and delivering them to the FPGA. The key data transfer process is as follows:

1. **Data Transmission (CPU to FPGA)**:
   - The CPU encapsulates application data into a distinguishable frame (with **app_id**).
   - The RAH Services send this frame to the FPGA.
   - The FPGA decodes the frame and writes it into the appropriate **APP_WR_FIFO**.

2. **Data Processing and Response (FPGA to CPU)**:
   - The FPGA processes the data and writes the result into **APP_RD_FIFO**.
   - The RAH Services encapsulate this data and send it back to the CPU.
   - The CPU decodes the frame and extracts the computed results.

This structured communication ensures an efficient and organized transfer of data between the CPU and FPGA, making real-time computations feasible.

## Functions of Divider
The divider module provides the following functions:

- **Supports Signed and Unsigned Division**
- **Pipelined Architecture** for faster computations
- **Takes 8-bit/16-bit/24-bit/32-bit Numerator and Denominator**
- **Returns 32-bit Quotient and Remainder**

## FPGA User Guide

### Divider Design (Signed & Unsigned)

For designing a **signed** or **unsigned** divider, the **APP ID** must be updated accordingly:
- **Unsigned Divider** → Set `APP ID = 1`
- **Signed Divider** → Set `APP ID = 2`

This ensures the correct operation mode based on the type of division required.

The FPGA receives input frames via the RAH communication interface. The input frame format for the divider processing is structured as follows:

### Input Frame Format
Each input frame consists of **4 bytes (32-bit format)**:
1. **First Byte:** Width selection:
   - `1` → 8-bit
   - `2` → 16-bit
   - `3` → 24-bit
   - `4` → 32-bit
2. **Second Byte:** Indicates whether the value is:
   - `1` → Numerator
   - `0` → Denominator
3. **Remaining Two Bytes:** Hold the actual input value

 ![image](images/input_data_frame_structure.svg)

Example:
- If width is **8-bit** and the value of **Numerator** is `4`, the input frame would be:
  - `01 01 00 00 00 04`


The FPGA decodes the incoming frame, extracts the numerator and denominator, performs the division operation, and returns the computed quotient and remainder in an output frame.

### Output Frame Format
Each output frame consists of **4 bytes (32-bit format)**:
1. **First Two Bytes:** Reserved for future use
2. **Last Two Bytes:** Indicate whether the value is a **quotient** or **remainder**

![image](images/output_data_frame_structure.svg)

This structure ensures clarity in data processing and interpretation.

