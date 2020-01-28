module Bartender(clk, bluetooth_data, fpga_rst, bluetooth_send, drink_open, motor_signal, is_busy, LED, LED_drink_open);
	input clk;
	input [5-1:0] bluetooth_data;
	input fpga_rst;
	input bluetooth_send;
	output [0:8-1] drink_open;
	output [3:0] motor_signal;
	output is_busy;
	output [5-1:0] LED; //
	output [0:8-1] LED_drink_open;
	
	parameter WAIT = 3'd0;
	parameter ADD = 3'd1;
	parameter SWITCH = 3'd2;
	parameter END = 3'd3;
	
	wire [3-1:0] state;
	wire rst_de, rst;  // bluetooth_reset debounce+onepulse
	wire motor_enable, motor_direction;
	wire send_signal_de, send_signal;
	
	assign LED_drink_open = drink_open;
	
	debounce debounce_0(.clk(clk), .btn_debounced(rst_de), .btn(fpga_rst));
	one_pulse one_pulse_0(.clk(clk), .btn_one_pulse(rst), .btn_debounced(rst_de));
	
	debounce debounce_1(.clk(clk), .btn_debounced(send_signal_de), .btn(bluetooth_send));
	one_pulse one_pulse_1(.clk(clk), .btn_one_pulse(send_signal), .btn_debounced(send_signal_de));
	
	motor_controller motor_controller_0(.state(state), .motor_enable(motor_enable), .motor_direction(motor_direction));
	// bluetooth_data -> input_drink
	main_design main_design_0(.clk(clk), .rst(rst), .input_drink(bluetooth_data), .send_signal(send_signal), .drink_open(drink_open), .is_busy(is_busy), .state(state), .LED(LED));
	pmod_step_interface pmod_step_interface_0(.clk(clk), .rst(rst), .direction(motor_direction), .en(motor_enable), .signal_out(motor_signal));
	
endmodule

module main_design(clk, rst, input_drink, send_signal, drink_open, is_busy, state, LED);
	input clk;
	input rst;
	input [5-1:0] input_drink;
	input send_signal;
	output [0:8-1] drink_open;
	output is_busy;
	output reg [3-1:0] state;
	output [5-1:0] LED;
	
	parameter WAIT = 3'd0;
	parameter ADD = 3'd1;
	parameter SWITCH = 3'd2;
	parameter END = 3'd3;
	
	reg [5-1:0] which_drink, next_which_drink;
	reg [3-1:0] next_state;
	wire [7-1:0] drink_proportion; // fixed value per material, = material proportion.
	reg [4-1:0] count_switch, next_count_switch; // for SWITCH->ADD state
	
	wire motor_count, valve_count, motor_rst, valve_rst; // if 1, reset.
	
	drink_proportion_sender drink_proportion_sender_0(.input_drink(which_drink), .material(count_switch), .material_proportion(drink_proportion));
	valve_counter #(10) valve_counter_0(.clk(clk), .reset(valve_rst), .proportion(drink_proportion), .count(valve_count));
	motor_counter #(260) motor_counter_0(.clk(clk), .reset(motor_rst), .count(motor_count));
	
	assign motor_rst = (state == ADD && next_state == SWITCH)? 1: 0;
	assign valve_rst = ((state == WAIT && next_state == ADD)||(state == SWITCH && next_state == ADD))? 1: 0;
	
	// signals for valves drivers
	assign drink_open[0] = (state == ADD && count_switch == 0)? 1: 0;
	assign drink_open[1] = (state == ADD && count_switch == 1)? 1: 0;
	assign drink_open[2] = (state == ADD && count_switch == 2)? 1: 0;
	assign drink_open[3] = (state == ADD && count_switch == 3)? 1: 0;
	assign drink_open[4] = (state == ADD && count_switch == 4)? 1: 0;
	assign drink_open[5] = (state == ADD && count_switch == 5)? 1: 0;
	assign drink_open[6] = (state == ADD && count_switch == 6)? 1: 0;
	assign drink_open[7] = (state == ADD && count_switch == 7)? 1: 0;
	
	assign LED = which_drink;

	always@(posedge clk) begin
		if(rst) begin
			state <= WAIT;
			count_switch <= 4'd0;
			which_drink <= 5'd31;
		end else begin
			state <= next_state;
			count_switch <= next_count_switch;
			which_drink <= next_which_drink;
		end
	end
	
	always@(*)begin
		case(state)
			WAIT: begin
				if(send_signal) begin
					next_state = ADD;
					next_count_switch = 4'd0;
					next_which_drink = input_drink;
				end else begin
					next_state = WAIT;
					next_count_switch = 4'd0;
					next_which_drink = 5'd31;
				end
			end
			ADD: begin
				next_which_drink = which_drink;
				if(count_switch == 8) begin
					next_state = END;
				end else begin
					if(valve_count) begin
						next_state = SWITCH;
					end else begin
						next_state = ADD;
					end
				end
				next_count_switch = (state == ADD && next_state == SWITCH)? count_switch + 1: count_switch; // how many times to add and switch? 8
			end
			SWITCH: begin
				next_which_drink = which_drink;
				next_count_switch = count_switch;
				if(motor_count) begin
					next_state = ADD;
				end else begin
					next_state = SWITCH;
				end
			end
			END: begin
				next_which_drink = 5'd31;
				next_count_switch = 4'd0;
				next_state = WAIT;
			end
		endcase
	end
	
	assign is_busy = (state == END || state == WAIT)? 0: 1;
	
endmodule

module motor_controller(state, motor_enable, motor_direction);
	input [3-1:0] state;
	output motor_enable;
	output motor_direction;
	
	parameter WAIT = 3'd0;
	parameter ADD = 3'd1;
	parameter SWITCH = 3'd2;
	parameter END = 3'd3;
	
	assign motor_enable = (state == SWITCH)? 1: 0;
	assign motor_direction = 1;
endmodule

module motor_counter #(parameter n = 25)(clk, reset, count);
	input clk, reset;
	output count;
	
	reg [31-1:0] i;
	wire [31-1:0] next_i;
	
	always @ (posedge clk or posedge reset) begin
		if(reset)
			i <= 0;
		else begin
			if(i >= n * 1000000)
				i <= 0;
			else
				i <= next_i;
		end
	end
	
	assign next_i = i + 1;
	assign count = (i == n * 1000000)? 1: 0;
	
endmodule

module valve_counter #(parameter n = 25)(clk, reset, proportion, count);
	input clk, reset;
	input [7-1:0] proportion;
	output count;
	
	reg [38-1:0] i;
	wire [38-1:0] next_i;
	
	always @ (posedge clk or posedge reset) begin
		if(reset)
			i <= 0;
		else begin
			if(i >= n * proportion * 10000000)
				i <= 0;
			else
				i <= next_i;
		end
	end
	
	assign next_i = i + 1;
	assign count = (i == n * proportion * 10000000)? 1: 0;
	
endmodule

module drink_proportion_sender(input_drink, material, material_proportion);
	input [5-1:0] input_drink;
	input [4-1:0] material;
	output reg [7-1:0] material_proportion;
	// Drinks' material proportion
	parameter [6:0] drink0 [0:7] = {7'd1, 7'd1, 7'd1, 7'd1, 7'd1, 7'd10, 7'd1, 7'd1};
	parameter [6:0] drink1 [0:7] = {7'd1, 7'd1, 7'd7, 7'd7, 7'd7, 7'd7, 7'd3, 7'd3};
	parameter [6:0] drink2 [0:7] = {7'd1, 7'd1, 7'd30, 7'd1, 7'd1, 7'd1, 7'd10, 7'd1};
	parameter [6:0] drink3 [0:7] = {7'd1, 7'd1, 7'd1, 7'd30, 7'd1, 7'd1, 7'd10, 7'd1};
	parameter [6:0] drink4 [0:7] = {7'd1, 7'd1, 7'd1, 7'd30, 7'd1, 7'd1, 7'd1, 7'd10};
	parameter [6:0] drink5 [0:7] = {7'd1, 7'd1, 7'd1, 7'd1, 7'd30, 7'd1, 7'd10, 7'd1};
	parameter [6:0] drink6 [0:7] = {7'd1, 7'd1, 7'd20, 7'd1, 7'd1, 7'd1, 7'd10, 7'd10};
	
	// drinks proportion to be determined.
	parameter [6:0] drink7 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink8 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink9 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink10 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink11 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink12 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink13 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink14 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink15 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink16 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink17 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink18 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink19 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink20 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink21 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink22 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink23 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink24 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink25 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink26 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink27 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink28 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink29 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	parameter [6:0] drink30 [0:7] = {7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3, 7'd3};
	// ...
	
	always@(*)begin
		case(input_drink)
			0: material_proportion = drink0[material];
			1: material_proportion = drink1[material];
			2: material_proportion = drink2[material];
			3: material_proportion = drink3[material];
			4: material_proportion = drink4[material];
			5: material_proportion = drink5[material];
			6: material_proportion = drink6[material];
			7: material_proportion = drink7[material];
			8: material_proportion = drink8[material];
			9: material_proportion = drink9[material];
			10: material_proportion = drink10[material];
			11: material_proportion = drink11[material];
			12: material_proportion = drink12[material];
			13: material_proportion = drink13[material];
			14: material_proportion = drink14[material];
			15: material_proportion = drink15[material];
			16: material_proportion = drink16[material];
			17: material_proportion = drink17[material];
			18: material_proportion = drink18[material];
			19: material_proportion = drink19[material];
			20: material_proportion = drink20[material];
			21: material_proportion = drink21[material];
			22: material_proportion = drink22[material];
			23: material_proportion = drink23[material];
			24: material_proportion = drink24[material];
			25: material_proportion = drink25[material];
			26: material_proportion = drink26[material];
			27: material_proportion = drink27[material];
			28: material_proportion = drink28[material];
			29: material_proportion = drink29[material];
			30: material_proportion = drink30[material];
		endcase
	end
	
endmodule

module debounce (btn_debounced, btn, clk);
	output btn_debounced; // signal of a pushbutton after being debounced
	input btn; // signal from a pushbutton
	input clk;
	reg [3:0] DFF; // use shift_reg to filter pushbutton bounce
	always @(posedge clk) begin
		DFF[3:1] <= DFF[2:0];
		DFF[0] <= btn;
	end
	assign btn_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);
endmodule

module one_pulse(clk, btn_debounced, btn_one_pulse);
	input clk, btn_debounced;
	output reg btn_one_pulse;
	
	reg delay;
	
	always@ (posedge clk) begin
		btn_one_pulse <= btn_debounced & (!delay);
		delay <= btn_debounced;
	end
endmodule
	