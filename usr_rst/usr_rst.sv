`default_nettype none

module usr_rst #(
    parameter CLK_FREQUENCY = 48000000,
    parameter BUTTON_LOGIC_LEVEL = 1,
    parameter SYS_RESET_LOGIC_LEVEL = 1,
    parameter SYS_RESET_LOGIC_DEBOUNCE_MS = 10,
    parameter BOOT_RESET_LOGIC_LEVEL = 1,
    parameter BOOT_LONG_PRESS_DURATION_MS = 1000
)
(
    input wire clk48,
    
    // RGB LED
    output logic rgb_led0_r,
    output logic rgb_led0_g,
    output logic rgb_led0_b,
    
    // UART
    //input wire din,
    output wire din,
    output wire dout,
    
    // reset->boot
    output wire rst_n,
    input wire usr_btn
    
    // Debug pins
    ,output wire dbg5
);
    // ------------------------------------------------------------
    // System reset
    logic sys_rst;
    
    // reset system or boot
    sys_boot_rst #(
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .BUTTON_LOGIC_LEVEL(BUTTON_LOGIC_LEVEL),
        .SYS_RESET_LOGIC_LEVEL(SYS_RESET_LOGIC_LEVEL),
        .SYS_RESET_LOGIC_DEBOUNCE_MS(SYS_RESET_LOGIC_DEBOUNCE_MS),
        .BOOT_RESET_LOGIC_LEVEL(BOOT_RESET_LOGIC_LEVEL),
        .BOOT_LONG_PRESS_DURATION_MS(BOOT_LONG_PRESS_DURATION_MS)
    )
    sys_boot_rst_inst(
        .clk(clk48),
        .usr_btn(usr_btn),
        .sys_rst(sys_rst),
        .boot_rst(rst_n),
        .mon_cnt(dbg5)
    );
    
    // ------------------------------------------------------------
    // Every positive edge increment register by 1
    logic [26:0] counter = 0;
    always_ff @(posedge clk48) begin
        if(sys_rst) begin
            counter <= '0;
        end else begin
            counter <= counter + 1;
        end
    end
    
    // ------------------------------------------------------------
    // Change between rgb with reset pressed
    // Logic Level: LOW
    localparam RGB_LOGIC_LEVEL = 0;
    typedef enum {RED, GREEN, BLUE} rgb_fsm_state;
    rgb_fsm_state rgb_fsm = RED;
    
    always_ff @(posedge clk48) begin
        // Active low
        rgb_led0_r <= ~RGB_LOGIC_LEVEL;
        rgb_led0_g <= ~RGB_LOGIC_LEVEL;
        rgb_led0_b <= ~RGB_LOGIC_LEVEL;
        case(rgb_fsm)
            RED: begin
                rgb_led0_r <= RGB_LOGIC_LEVEL;
                if(sys_rst) begin
                    rgb_fsm <= GREEN;
                end 
            end
            
            GREEN: begin
                rgb_led0_g <= RGB_LOGIC_LEVEL;
                if(sys_rst) begin
                    rgb_fsm <= BLUE;
                end 
            end
            
            BLUE: begin
                rgb_led0_b <= RGB_LOGIC_LEVEL;
                if(sys_rst) begin
                    rgb_fsm <= RED;
                end 
            end
        endcase
    end
    
    // ------------------------------------------------------------
    // UART
    assign dout = usr_btn;
    assign din  = sys_rst;
    
endmodule
