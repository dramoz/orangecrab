/* Copyright 2020 Gregory Davill <greg.davill@gmail.com>, 2020 Chris Marc Dailey (cmd) <nitz@users.noreply.github.com> */
`default_nettype none

module top (
    input wire clk48,
    
    // RGB LED
    output wire rgb_led0_r,
    output wire rgb_led0_g,
    output wire rgb_led0_b,
    
    // UART
    input wire uart_rx,
    output wire uart_tx,
    
    // reset->boot
    output wire rst_n,
    input wire usr_btn
);
    // Create a 27 bit register
    logic [26:0] counter = 0;
    
    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        counter <= counter + 1;
    end
    
    // Output inverted values of counter onto LEDs
    assign rgb_led0_r = ~counter[24];
    assign rgb_led0_g = ~counter[25];
    assign rgb_led0_b = 1;
    
    // UART
    assign uart_tx = (uart_rx==1'b1)?(counter[9]):(counter[19]);
    
    // reset to boot
    orangecrab_reset reset_instance(
        .clk(clk48),
        .do_reset(~usr_btn),
        .nreset_out(rst_n)
    );

endmodule
