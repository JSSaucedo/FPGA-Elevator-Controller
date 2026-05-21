module elevador_top
(
    input  clk,
    input  i_rst_n,
	 
    input  [1:0] seleccion_piso,
	 
    input  sensor1,
    input  sensor2,
    input  sensor3,
	 
    output o_puertas,
	 
    output o_motor_up,
    output o_motor_down,
	 
    output led1,
    output led2,
    output led3,
	 
    output motor_in1,
    output motor_in2,
    output motor_in3,
    output motor_in4,
    
    output [6:0] hex0
);

wire i_rst = ~i_rst_n;

wire motor_up_fsm;
wire motor_down_fsm;
wire puertas_fsm;

// Sincronizadores adicionales para el display
reg s1_meta, s1_sync;
reg s2_meta, s2_sync;
reg s3_meta, s3_sync;

always @(posedge clk or posedge i_rst) begin
    if (i_rst) begin
        s1_meta <= 1'b0; s1_sync <= 1'b0;
        s2_meta <= 1'b0; s2_sync <= 1'b0;
        s3_meta <= 1'b0; s3_sync <= 1'b0;
    end else begin
        // Invertimos el FC-51 (activo en bajo) antes de sincronizar
        s1_meta <= ~sensor1; s1_sync <= s1_meta;
        s2_meta <= ~sensor2; s2_sync <= s2_meta;
        s3_meta <= ~sensor3; s3_sync <= s3_meta;
    end
end

// FSM NO HAY CAMBIOS EXACTAMENETE MISMOS PUERTOS
maquina_estados_elevador u_fsm (
    .clk            (clk),
    .i_rst_n        (i_rst_n),
    .seleccion_piso (seleccion_piso),
    .sensor1        (sensor1),
    .sensor2        (sensor2),
    .sensor3        (sensor3),
    .o_puertas      (puertas_fsm),
    .o_motor_up     (motor_up_fsm),
    .o_motor_down   (motor_down_fsm),
    .led1           (led1),
    .led2           (led2),
    .led3           (led3)
);

assign o_motor_up   = motor_up_fsm;
assign o_motor_down = motor_down_fsm;
assign o_puertas    = puertas_fsm;

// Driver motor subida/bajada
stepper_driver u_stepper_elevador (
    .clk        (clk),
    .i_rst      (i_rst),
    .enable_up  (motor_up_fsm),
    .enable_down(motor_down_fsm),
    .in1        (motor_in1),
    .in2        (motor_in2),
    .in3        (motor_in3),
    .in4        (motor_in4)
);

// display del piso actual
piso_display u_display (
    .clk         (clk),
    .i_rst       (i_rst),
    .sensor1_sync(s1_sync),
    .sensor2_sync(s2_sync),
    .sensor3_sync(s3_sync),
    .hex0        (hex0)
);

endmodule