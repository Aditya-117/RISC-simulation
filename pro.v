`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:33 11/30/2023 
// Design Name: 
// Module Name:    pro 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////
module slow(
input clk,
output reg oclk
    );
	 reg [27:0] count;
	 initial
	 begin
	 count=0;
	 oclk=0;
	 end
	 always @(posedge clk)
	 begin
	 if(count> 16777216)
	 begin
	 count=0;
	 oclk=~oclk;
	 end
	 else
	 count=count+1;
	 end
endmodule

module pro (
  input clk,            // Clock input
  input rst,            // Reset input
  output reg [7:0] result,    // 8-bit result output
  output reg [6:0] Y,  // 7-bit output representing segments '0' through 'J'
  output reg [3:0] X
);

// Internal registers
reg [7:0] pc;   // Program counter
reg [7:0] acc; // Accumulator
reg [7:0] IR; // Instruction register
reg [7:0] temp;

initial begin
X <= 4'b0001;
end

// File I/O variables
reg [7:0] mem [0:7]; // Memory array to store instructions
initial begin
  $readmemh("memfile.txt", mem); // Reading memory
  pc <= 8'b0;
  IR <= mem[pc]; // Initial fetch
end

slow a1(clk, oclk);

always @(posedge oclk or posedge rst) begin
  if (rst) begin
    // Reset logic
    pc <= 8'b0;
    acc <= 8'b0;
  end else begin
    // Decode and perform operations
    case (IR[7:4])
      4'b0001: begin  // Load
		acc <= IR[3:0];
		result <= acc;
		end
      4'b0010: begin // Add
		acc<= acc+ IR[3:0];
		result <= acc; 
		end
      4'b0011: begin 
		pc<= pc+ IR[3:0]; // Jump unconditional
		temp<= 8'b11111111;
      result<= temp;
		end
		4'b0100: begin		// Compare
		if(acc < IR[3:0]) begin
		acc <= 8'b11111110; // Greater
      result <= acc;
		end
		else if(acc > IR[3:0]) begin
		acc <= 8'b11111101;
		result <= acc; // Lesser
		end
		else begin
		acc <= 8'b11111100;
		result <= acc; // Equal
		end
		end
      //default: result <= 8'b10000000; // HALT
    endcase
	 case (result)
    8'b00000000: Y = 7'b0000001; // Display '0'
    8'b00000001: Y = 7'b1001111; // Display '1'
    8'b00000010: Y = 7'b0010010; // Display '2'
    8'b00000011: Y = 7'b0000110; // Display '3'
    8'b00000100: Y = 7'b1001100; // Display '4'
    8'b00000101: Y = 7'b0100100; // Display '5'
    8'b00000110: Y = 7'b0100000; // Display '6'
    8'b00000111: Y = 7'b0001111; // Display '7'
    8'b00001000: Y = 7'b0000000; // Display '8'
    8'b00001001: Y = 7'b0000100; // Display '9'
	 8'b00001010: Y = 7'b0001000; // Display 'A'
	 8'b00001011: Y = 7'b1100000; // Display 'b'
	 8'b00001100: Y = 7'b0110001; // Display 'C'
	 8'b00001101: Y = 7'b1000010; // Display 'd'
	 8'b00001110: Y = 7'b0110000; // Display 'E'
	 8'b00001111: Y = 7'b0111000; // Display 'F'
	 8'b11111110: Y = 7'b0100001; // Display 'G'
	 8'b11111101: Y = 7'b1110001; // Display 'L'
	 8'b11111111: Y = 7'b1000011; // Display 'J'
	 8'b11111100: Y = 7'b0110000; // Display 'E'
	 8'b10000000: Y = 7'b1001000; // Display 'H'
    default: Y = 7'b1111111; // Turn off all segments for an unknown input
  endcase
  // Fetch
    IR <= mem[pc];
	 pc <= pc + 1;
  end
end

endmodule
