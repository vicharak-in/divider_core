# Divider Application Design using Verilog on FPGA with RAH

## Introduction to Divider
A divider circuit is a fundamental component used to perform division operations in digital circuits. This project implements a hardware-based division operation using Verilog on an FPGA. The design includes support for both **signed** and **unsigned** inputs, making it versatile for various computational applications. Additionally, it is implemented with **pipeline stages**, ensuring efficient execution of division operations.

This project serves as an application example using the **Real-time Application Handler (RAH)** protocol, which enables seamless communication between the CPU and FPGA.

## Understanding RAH (Real-time Application Handler)
RAH is a protocol developed by Vicharak to enable efficient and real-time data transfer between the CPU and FPGA. It allows the CPU to manage multiple applications simultaneously by encapsulating their data into structured frames, each identified by a unique app_id, and routing them to the appropriate logic on the FPGA.

## Functions of Divider
The divider module provides the following functions:

- **Supports Signed and Unsigned Division**
- **Pipelined Architecture** for faster computations
- **Takes 8-bit/16-bit/24-bit/32-bit/64-bit Numerator and Denominator**
- **Returns 64-bit Quotient and Remainder**

## FPGA User Guide

### Divider Design (Signed & Unsigned)

For designing a **signed** or **unsigned** divider, the **APP ID** must be updated accordingly:
- **Unsigned Divider** → Set `APP ID = 1`
- **Signed Divider** → Set `APP ID = 2`

This ensures the correct operation mode based on the type of division required.

The FPGA receives input frames via the RAH communication interface. The input frame format for the divider processing is structured as follows:

### Input Frame Format
Input frame consists of **18 bytes (144-bit format)**:
1. **1 byte:** Reserved 
2. **1 Byte:** Width selection:
   - `1` → 8-bit
   - `2` → 16-bit
   - `3` → 24-bit
   - `4` → 32-bit
   - `5` → 64-bit
3. **8 bytes:** Hold the actual input value of Numerator
4. **8 bytes:** Hold the actual input value of Denominator
  
<div align="center">

![image](images/input_data_frame_structure.svg)

</div>

Example:
- If width is **8-bit** and the value of **Numerator** is `4` and the value of **Denominator** is `2`,the input frame would be:
  - `00 01 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 02`


The FPGA decodes the incoming frame, extracts the numerator and denominator, performs the division operation, and returns the computed quotient and remainder in an output frame.

### Output Frame Format
Output frame consists of **18 bytes (144-bit format)**:
1. **1 Byte:** Indicate whether the value is a **quotient** or **remainder**
   - `a` → quotient
   - `b` → remainder
2. **8 bytes:** Hold the actual output value of quotient
3. **1 Byte:** Indicate whether the value is a **quotient** or **remainder**
   - `a` → quotient
   - `b` → remainder
4. **8 bytes:** Hold the actual output value of remainder

<div align="center">

![image](images/output_data_frame_structure.svg)

</div>

Example:
- `0a 00 00 00 00 00 00 00 02 00 00 00 0b 00 00 00 00 00 00 00 00 00 00 00`

This structure ensures clarity in data processing and interpretation.

## RAH Protocol User Guide - Resources

1. **[CPU Usage Guide](https://github.com/vicharak-in/rah-bit/blob/master/docs/cpu-usage-guide.md)**:
   This guide will provide detailed instructions on how to set up and use the RAH protocol on the CPU side.

2. **[FPGA Implementation Guide](https://github.com/vicharak-in/rah-bit/blob/master/docs/fpga-implementation.md)**:
   This guide covers the FPGA side of the RAH protocol .

3. **[RAH Example Integration](https://github.com/vicharak-in/rah-bit/blob/master/docs/rah-example-integration.md)**:
   This document provides a step-by-step example of integrating the RAH protocol between the CPU and FPGA, demonstrating the complete flow from data generation on the CPU to processing on the FPGA and back.
