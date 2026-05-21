module piso_display
(
    input  clk,
    input  i_rst,
    input  sensor1_sync,
    input  sensor2_sync,
    input  sensor3_sync,
    output [6:0] hex0  //PRIMER DISPLAY DE LA FPGA        
);

// piso actual fisico (1 2 o 3)
reg [1:0] piso_actual;

always @(posedge clk or posedge i_rst) begin
    if (i_rst) begin
        piso_actual <= 2'd1;
    end 
	 else begin
	 
        /* Prioridad descendente: si dos sensores se activan simultaneamente
        (no deberia pasar fisicamente), se elige el de mayor numero.
        // Si NINGUN sensor esta activo, conserva el ultimo valor. */
		  
		  
        if (sensor3_sync)
            piso_actual <= 2'd3;
        else if (sensor2_sync)
            piso_actual <= 2'd2;
        else if (sensor1_sync)
            piso_actual <= 2'd1;
        // else: mantiene el valor anterior
    end
end


reg [6:0] segmentos;

always @* begin
    case (piso_actual)
        2'd1:    segmentos = 7'b0000110;  
        2'd2:    segmentos = 7'b1011011;   
        2'd3:    segmentos = 7'b1001111;   
        default: segmentos = 7'b0000000;
    endcase
end

// Inversion: el display de la DE10-Lite es active-low
assign hex0 = ~segmentos;

endmodule