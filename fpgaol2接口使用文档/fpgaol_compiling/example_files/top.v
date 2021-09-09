`timescale 1ns / 1ps
        //////////////////////////////////////////////////////////////////////////////////
        // Company: 
        // Engineer: FPGAOL Dev Group
        // 
        // Create Date: 19.08.2019 13:01:37
        // Design Name: 
        // Module Name: echo
        // Project Name: FPGAOL Example Project
        // Target Devices: 
        // Tool Versions: 
        // Description: 
        // 
        // Dependencies: 
        // 
        // Revision:
        // Revision 0.01 - File Created
        // Additional Comments:
        // 
        //////////////////////////////////////////////////////////////////////////////////
        
        
        module top(
            input [7:0] sw,
            output [7:0] led
            );
        
        assign led = sw;
        
        endmodule
        