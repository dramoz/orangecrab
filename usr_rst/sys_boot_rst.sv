`default_nettype none

// Send system reset or boot_rst on double click

module sys_boot_rst #(
    parameter CLK_FREQUENCY = 48000000,
    parameter BUTTON_LOGIC_LEVEL = 1,
    parameter SYS_RESET_LOGIC_LEVEL = 1,
    parameter SYS_RESET_LOGIC_DEBOUNCE_MS = 10,
    parameter BOOT_RESET_LOGIC_LEVEL = 1,
    parameter BOOT_LONG_PRESS_DURATION_MS = 1000
)
(
    input  wire clk,
    input  wire usr_btn,
    output logic sys_rst,
    output logic boot_rst
);
    // Reset logic
    logic [1:0] xor_path;
    localparam sys_CLKS = $rtoi($ceil(CLK_FREQUENCY/1000*SYS_RESET_LOGIC_DEBOUNCE_MS));
    localparam boot_CLKS = $rtoi($ceil(CLK_FREQUENCY/1000*BOOT_LONG_PRESS_DURATION_MS));
    localparam BOOT_CNT_WL = $clog2(boot_CLKS);
    logic [BOOT_CNT_WL:0] boot_counter = '0;
    
    // Send proper rst
    assign sys_rst   = (boot_counter==sys_CLKS) ? (SYS_RESET_LOGIC_LEVEL) : (~SYS_RESET_LOGIC_LEVEL);
    assign boot_rst  = (boot_counter>=boot_CLKS) ? (BOOT_RESET_LOGIC_LEVEL):(~BOOT_RESET_LOGIC_LEVEL);
    
    always @(posedge clk)  begin
        xor_path <= {xor_path[0], usr_btn};
        if(^xor_path) begin
            boot_counter <= '0;
        end else begin
            if(xor_path[1]==BUTTON_LOGIC_LEVEL) begin
                if(boot_counter <= boot_CLKS) begin
                    boot_counter <= boot_counter + 1;
                end else begin
                end
            end else begin
                boot_counter <= '0;
            end
        end
    end
    
endmodule
