module maquina_estados_elevador
(
    input clk,
    input i_rst_n,                    // Activo en bajo (KEY1 push-button)
    input [1:0] seleccion_piso,       // 01=Piso1, 10=Piso2, 11=Piso3
    input sensor1,                    // FC-51 
    input sensor2,                    
    input sensor3,                    
    output o_puertas,
    output o_motor_up,
    output o_motor_down,
    output led1,
    output led2,
    output led3
);

// inversion del reset
wire i_rst = ~i_rst_n;

// INVERTIR LOS SENSORES, SOLO ESTAN ACTIVOS EN BAJO/0
wire sensor1_pos = ~sensor1;
wire sensor2_pos = ~sensor2;
wire sensor3_pos = ~sensor3;

// definicion de estados
localparam [2:0] floor1    = 3'b001,
                 floor2    = 3'b010,
                 floor3    = 3'b011,
                 move_up   = 3'b100,
                 move_down = 3'b101;

reg [2:0] state, state_next;
reg [1:0] destino, destino_next;


// Sincronizadores de 2 etapas para entradas asincronas
reg sensor1_meta, sensor1_sync;
reg sensor2_meta, sensor2_sync;
reg sensor3_meta, sensor3_sync;
reg [1:0] seleccion_meta, seleccion_sync;


/* Todo reg asignado dentro de un always @(posedge clk) se sintetiza como un flip-flop tipo D.
ESTA ES LA CASCADA DE FLIFLOPS PARA RESOLVER EL PROBLEMA DE METAESTABILIDAD, SINCRONIZANDO LO ASINCRONO*/


always @(posedge clk or posedge i_rst) begin
    if (i_rst) begin
        sensor1_meta   <= 1'b0;  
		  sensor1_sync   <= 1'b0;
		  
        sensor2_meta   <= 1'b0;  
		  sensor2_sync   <= 1'b0;
		  
        sensor3_meta   <= 1'b0;  
		  sensor3_sync   <= 1'b0;
		  
        seleccion_meta <= 2'b00; 
		  seleccion_sync <= 2'b00;
		  
    end else begin
        sensor1_meta   <= sensor1_pos;    
		  sensor1_sync   <= sensor1_meta;
		  
        sensor2_meta   <= sensor2_pos;    
		  sensor2_sync   <= sensor2_meta;
		  
        sensor3_meta   <= sensor3_pos;    
		  sensor3_sync   <= sensor3_meta;
		  
        seleccion_meta <= seleccion_piso; 
		  seleccion_sync <= seleccion_meta;
    end
end



// salidas moore
assign o_motor_up   = (state == move_up);
assign o_motor_down = (state == move_down);
assign o_puertas    = ~(o_motor_up | o_motor_down);
assign led1 = (state == floor1);
assign led2 = (state == floor2);
assign led3 = (state == floor3);

// registro de estado y destino y el reset lleva al piso 1
always @(posedge clk or posedge i_rst) begin
    if (i_rst) begin
        state   <= floor1;
        destino <= 2'b01;
    end else begin
        state   <= state_next;
        destino <= destino_next;
    end
end

// Logica de siguiente estado
always @* begin
    state_next   = state;
    destino_next = destino; //DESTINO ES UN REGISTRO QUE ALMACENA EL PISO SELECCIONADO PARA QUE MOVEUP SEPA DONDE DETENERSE, NO ES NECESARIO PERO SI NO AUMENTAN LA CANTIDAD DE ESTADOS
	 
    case (state)
        floor1: begin
            if (seleccion_sync == 2'b10) begin   //SELECCION DEL PISO DOS
                destino_next = 2'b10;
                state_next  = move_up;
            end 
				else if (seleccion_sync == 2'b11) begin //SELECCION DEL PISO 3
                destino_next = 2'b11;
                state_next  = move_up;
            end
        end
		  
        floor2: begin
            if (seleccion_sync == 2'b11) begin //SELECCION DEL PISO 3
                destino_next = 2'b11;
                state_next   = move_up;
					 
            end 
				else if (seleccion_sync == 2'b01) begin  //SELECCION DEL PISO 1
                destino_next = 2'b01;
                state_next  = move_down;
            end
        end
		  
        floor3: begin
            if (seleccion_sync == 2'b01) begin   //SELECCION DEL PISO 1 
                destino_next = 2'b01;
                state_next   = move_down;
            end 
				else if (seleccion_sync == 2'b10) begin //SELECCION DEL PISO 2
                destino_next = 2'b10;
                state_next  = move_down;
            end
        end
		  
        move_up: begin
            if (destino == 2'b10 && sensor2_sync)
                state_next = floor2;
            else if (destino == 2'b11 && sensor3_sync)
                state_next = floor3;
        end
		  
        move_down: begin
            if (destino == 2'b10 && sensor2_sync)
                state_next = floor2;
            else if (destino == 2'b01 && sensor1_sync)
                state_next = floor1;
        end
		  
        default: state_next = floor1;
		  
    endcase
end

endmodule