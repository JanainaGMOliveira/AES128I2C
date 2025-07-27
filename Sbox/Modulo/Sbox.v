module sbox(
	output [7:0] dado,
	input  [7:0] endereco
);
	reg [7:0] auxDado;
    assign dado = auxDado;

    always @(*)
    begin
        case(endereco)
			8'h00: auxDado = 8'h63;    8'h40: auxDado = 8'h09;    8'h80: auxDado = 8'hCD;    8'hC0: auxDado = 8'hBA;
			8'h01: auxDado = 8'h7C;    8'h41: auxDado = 8'h83;    8'h81: auxDado = 8'h0C;    8'hC1: auxDado = 8'h78;
			8'h02: auxDado = 8'h77;    8'h42: auxDado = 8'h2C;    8'h82: auxDado = 8'h13;    8'hC2: auxDado = 8'h25;
			8'h03: auxDado = 8'h7B;    8'h43: auxDado = 8'h1A;    8'h83: auxDado = 8'hEC;    8'hC3: auxDado = 8'h2E;
			8'h04: auxDado = 8'hF2;    8'h44: auxDado = 8'h1B;    8'h84: auxDado = 8'h5F;    8'hC4: auxDado = 8'h1C;
			8'h05: auxDado = 8'h6B;    8'h45: auxDado = 8'h6E;    8'h85: auxDado = 8'h97;    8'hC5: auxDado = 8'hA6;
			8'h06: auxDado = 8'h6F;    8'h46: auxDado = 8'h5A;    8'h86: auxDado = 8'h44;    8'hC6: auxDado = 8'hB4;
			8'h07: auxDado = 8'hC5;    8'h47: auxDado = 8'hA0;    8'h87: auxDado = 8'h17;    8'hC7: auxDado = 8'hC6;
			8'h08: auxDado = 8'h30;    8'h48: auxDado = 8'h52;    8'h88: auxDado = 8'hC4;    8'hC8: auxDado = 8'hE8;
			8'h09: auxDado = 8'h01;    8'h49: auxDado = 8'h3B;    8'h89: auxDado = 8'hA7;    8'hC9: auxDado = 8'hDD;
			8'h0A: auxDado = 8'h67;    8'h4A: auxDado = 8'hD6;    8'h8A: auxDado = 8'h7E;    8'hCA: auxDado = 8'h74;
			8'h0B: auxDado = 8'h2B;    8'h4B: auxDado = 8'hB3;    8'h8B: auxDado = 8'h3D;    8'hCB: auxDado = 8'h1F;
			8'h0C: auxDado = 8'hFE;    8'h4C: auxDado = 8'h29;    8'h8C: auxDado = 8'h64;    8'hCC: auxDado = 8'h4B;
			8'h0D: auxDado = 8'hD7;    8'h4D: auxDado = 8'hE3;    8'h8D: auxDado = 8'h5D;    8'hCD: auxDado = 8'hBD;
			8'h0E: auxDado = 8'hAB;    8'h4E: auxDado = 8'h2F;    8'h8E: auxDado = 8'h19;    8'hCE: auxDado = 8'h8B;
			8'h0F: auxDado = 8'h76;    8'h4F: auxDado = 8'h84;    8'h8F: auxDado = 8'h73;    8'hCF: auxDado = 8'h8A;
			8'h10: auxDado = 8'hCA;    8'h50: auxDado = 8'h53;    8'h90: auxDado = 8'h60;    8'hD0: auxDado = 8'h70;
			8'h11: auxDado = 8'h82;    8'h51: auxDado = 8'hD1;    8'h91: auxDado = 8'h81;    8'hD1: auxDado = 8'h3E;
			8'h12: auxDado = 8'hC9;    8'h52: auxDado = 8'h00;    8'h92: auxDado = 8'h4F;    8'hD2: auxDado = 8'hB5;
			8'h13: auxDado = 8'h7D;    8'h53: auxDado = 8'hED;    8'h93: auxDado = 8'hDC;    8'hD3: auxDado = 8'h66;
			8'h14: auxDado = 8'hFA;    8'h54: auxDado = 8'h20;    8'h94: auxDado = 8'h22;    8'hD4: auxDado = 8'h48;
			8'h15: auxDado = 8'h59;    8'h55: auxDado = 8'hFC;    8'h95: auxDado = 8'h2A;    8'hD5: auxDado = 8'h03;
			8'h16: auxDado = 8'h47;    8'h56: auxDado = 8'hB1;    8'h96: auxDado = 8'h90;    8'hD6: auxDado = 8'hF6;
			8'h17: auxDado = 8'hF0;    8'h57: auxDado = 8'h5B;    8'h97: auxDado = 8'h88;    8'hD7: auxDado = 8'h0E;
			8'h18: auxDado = 8'hAD;    8'h58: auxDado = 8'h6A;    8'h98: auxDado = 8'h46;    8'hD8: auxDado = 8'h61;
			8'h19: auxDado = 8'hD4;    8'h59: auxDado = 8'hCB;    8'h99: auxDado = 8'hEE;    8'hD9: auxDado = 8'h35;
			8'h1A: auxDado = 8'hA2;    8'h5A: auxDado = 8'hBE;    8'h9A: auxDado = 8'hB8;    8'hDA: auxDado = 8'h57;
			8'h1B: auxDado = 8'hAF;    8'h5B: auxDado = 8'h39;    8'h9B: auxDado = 8'h14;    8'hDB: auxDado = 8'hB9;
			8'h1C: auxDado = 8'h9C;    8'h5C: auxDado = 8'h4A;    8'h9C: auxDado = 8'hDE;    8'hDC: auxDado = 8'h86;
			8'h1D: auxDado = 8'hA4;    8'h5D: auxDado = 8'h4C;    8'h9D: auxDado = 8'h5E;    8'hDD: auxDado = 8'hC1;
			8'h1E: auxDado = 8'h72;    8'h5E: auxDado = 8'h58;    8'h9E: auxDado = 8'h0B;    8'hDE: auxDado = 8'h1D;
			8'h1F: auxDado = 8'hC0;    8'h5F: auxDado = 8'hCF;    8'h9F: auxDado = 8'hDB;    8'hDF: auxDado = 8'h9E;
			8'h20: auxDado = 8'hB7;    8'h60: auxDado = 8'hD0;    8'hA0: auxDado = 8'hE0;    8'hE0: auxDado = 8'hE1;
			8'h21: auxDado = 8'hFD;    8'h61: auxDado = 8'hEF;    8'hA1: auxDado = 8'h32;    8'hE1: auxDado = 8'hF8;
			8'h22: auxDado = 8'h93;    8'h62: auxDado = 8'hAA;    8'hA2: auxDado = 8'h3A;    8'hE2: auxDado = 8'h98;
			8'h23: auxDado = 8'h26;    8'h63: auxDado = 8'hFB;    8'hA3: auxDado = 8'h0A;    8'hE3: auxDado = 8'h11;
			8'h24: auxDado = 8'h36;    8'h64: auxDado = 8'h43;    8'hA4: auxDado = 8'h49;    8'hE4: auxDado = 8'h69;
			8'h25: auxDado = 8'h3F;    8'h65: auxDado = 8'h4D;    8'hA5: auxDado = 8'h06;    8'hE5: auxDado = 8'hD9;
			8'h26: auxDado = 8'hF7;    8'h66: auxDado = 8'h33;    8'hA6: auxDado = 8'h24;    8'hE6: auxDado = 8'h8E;
			8'h27: auxDado = 8'hCC;    8'h67: auxDado = 8'h85;    8'hA7: auxDado = 8'h5C;    8'hE7: auxDado = 8'h94;
			8'h28: auxDado = 8'h34;    8'h68: auxDado = 8'h45;    8'hA8: auxDado = 8'hC2;    8'hE8: auxDado = 8'h9B;
			8'h29: auxDado = 8'hA5;    8'h69: auxDado = 8'hF9;    8'hA9: auxDado = 8'hD3;    8'hE9: auxDado = 8'h1E;
			8'h2A: auxDado = 8'hE5;    8'h6A: auxDado = 8'h02;    8'hAA: auxDado = 8'hAC;    8'hEA: auxDado = 8'h87;
			8'h2B: auxDado = 8'hF1;    8'h6B: auxDado = 8'h7F;    8'hAB: auxDado = 8'h62;    8'hEB: auxDado = 8'hE9;
			8'h2C: auxDado = 8'h71;    8'h6C: auxDado = 8'h50;    8'hAC: auxDado = 8'h91;    8'hEC: auxDado = 8'hCE;
			8'h2D: auxDado = 8'hD8;    8'h6D: auxDado = 8'h3C;    8'hAD: auxDado = 8'h95;    8'hED: auxDado = 8'h55;
			8'h2E: auxDado = 8'h31;    8'h6E: auxDado = 8'h9F;    8'hAE: auxDado = 8'hE4;    8'hEE: auxDado = 8'h28;
			8'h2F: auxDado = 8'h15;    8'h6F: auxDado = 8'hA8;    8'hAF: auxDado = 8'h79;    8'hEF: auxDado = 8'hDF;
			8'h30: auxDado = 8'h04;    8'h70: auxDado = 8'h51;    8'hB0: auxDado = 8'hE7;    8'hF0: auxDado = 8'h8C;
			8'h31: auxDado = 8'hC7;    8'h71: auxDado = 8'hA3;    8'hB1: auxDado = 8'hC8;    8'hF1: auxDado = 8'hA1;
			8'h32: auxDado = 8'h23;    8'h72: auxDado = 8'h40;    8'hB2: auxDado = 8'h37;    8'hF2: auxDado = 8'h89;
			8'h33: auxDado = 8'hC3;    8'h73: auxDado = 8'h8F;    8'hB3: auxDado = 8'h6D;    8'hF3: auxDado = 8'h0D;
			8'h34: auxDado = 8'h18;    8'h74: auxDado = 8'h92;    8'hB4: auxDado = 8'h8D;    8'hF4: auxDado = 8'hBF;
			8'h35: auxDado = 8'h96;    8'h75: auxDado = 8'h9D;    8'hB5: auxDado = 8'hD5;    8'hF5: auxDado = 8'hE6;
			8'h36: auxDado = 8'h05;    8'h76: auxDado = 8'h38;    8'hB6: auxDado = 8'h4E;    8'hF6: auxDado = 8'h42;
			8'h37: auxDado = 8'h9A;    8'h77: auxDado = 8'hF5;    8'hB7: auxDado = 8'hA9;    8'hF7: auxDado = 8'h68;
			8'h38: auxDado = 8'h07;    8'h78: auxDado = 8'hBC;    8'hB8: auxDado = 8'h6C;    8'hF8: auxDado = 8'h41;
			8'h39: auxDado = 8'h12;    8'h79: auxDado = 8'hB6;    8'hB9: auxDado = 8'h56;    8'hF9: auxDado = 8'h99;
			8'h3A: auxDado = 8'h80;    8'h7A: auxDado = 8'hDA;    8'hBA: auxDado = 8'hF4;    8'hFA: auxDado = 8'h2D;
			8'h3B: auxDado = 8'hE2;    8'h7B: auxDado = 8'h21;    8'hBB: auxDado = 8'hEA;    8'hFB: auxDado = 8'h0F;
			8'h3C: auxDado = 8'hEB;    8'h7C: auxDado = 8'h10;    8'hBC: auxDado = 8'h65;    8'hFC: auxDado = 8'hB0;
			8'h3D: auxDado = 8'h27;    8'h7D: auxDado = 8'hFF;    8'hBD: auxDado = 8'h7A;    8'hFD: auxDado = 8'h54;
			8'h3E: auxDado = 8'hB2;    8'h7E: auxDado = 8'hF3;    8'hBE: auxDado = 8'hAE;    8'hFE: auxDado = 8'hBB;
			8'h3F: auxDado = 8'h75;    8'h7F: auxDado = 8'hD2;    8'hBF: auxDado = 8'h08;    8'hFF: auxDado = 8'h16;
		endcase
    end
endmodule