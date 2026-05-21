module stepper_driver
(
    input  clk,
    input  i_rst,            // Activo en alto, internamente
    input  enable_up,        // = o_motor_up de la FSM
    input  enable_down,      // = o_motor_down de la FSM
    output reg in1,
    output reg in2,
    output reg in3,
    output reg in4
);

// Periodo entre pasos: 60000 ciclos a 50MHz = 1.2 ms/paso
// = ~833 pasos/seg = ~12.2 RPM en half-step (4096 pasos/vuelta)
localparam STEP_PERIOD = 32'd60000;

reg [31:0] tick_counter;
reg [2:0]  step_index;       // 0-7, indice en la secuencia half-step

always @(posedge clk or posedge i_rst) begin
    if (i_rst) begin
        tick_counter <= 32'd0;
        step_index   <= 3'd0;
    end else if (enable_up || enable_down) begin
        if (tick_counter >= STEP_PERIOD - 1) begin
            tick_counter <= 32'd0;
            if (enable_up)
                step_index <= step_index + 3'd1;   // avanza
            else
                step_index <= step_index - 3'd1;   // retrocede
        end else begin
            tick_counter <= tick_counter + 32'd1;
        end
    end else begin
        // Motor detenido: reinicia contador, mantiene step_index
        // (no resetea step_index para evitar saltos al reiniciar)
        tick_counter <= 32'd0;
    end
end

// Decodificacion de la secuencia half-step
always @* begin
    if (!enable_up && !enable_down) begin
        // Motor detenido: todas las bobinas apagadas (sin holding torque)
        {in1, in2, in3, in4} = 4'b0000;
    end else begin
        case (step_index)
            3'd0: {in1, in2, in3, in4} = 4'b1000;
            3'd1: {in1, in2, in3, in4} = 4'b1100;
            3'd2: {in1, in2, in3, in4} = 4'b0100;
            3'd3: {in1, in2, in3, in4} = 4'b0110;
            3'd4: {in1, in2, in3, in4} = 4'b0010;
            3'd5: {in1, in2, in3, in4} = 4'b0011;
            3'd6: {in1, in2, in3, in4} = 4'b0001;
            3'd7: {in1, in2, in3, in4} = 4'b1001;
        endcase
    end
end

endmodule