module tb_uart;

    // Declare signals to connect to the UART module
    reg reset;
    reg txclk;
    reg ld_tx_data;
    reg [7:0] tx_data;
    reg tx_enable;
    wire tx_out;
    wire tx_empty;
    reg rxclk;
    reg uld_rx_data;
    wire [7:0] rx_data;
    reg rx_enable;
    reg rx_in;
    wire rx_empty;

    // Instantiate the UART module
    uart uut (
        .reset(reset),
        .txclk(txclk),
        .ld_tx_data(ld_tx_data),
        .tx_data(tx_data),
        .tx_enable(tx_enable),
        .tx_out(tx_out),
        .tx_empty(tx_empty),
        .rxclk(rxclk),
        .uld_rx_data(uld_rx_data),
        .rx_data(rx_data),
        .rx_enable(rx_enable),
        .rx_in(rx_in),
        .rx_empty(rx_empty)
    );

    // Initialize signals
    initial begin
        reset = 1; // Reset active-high
        txclk = 0;
        ld_tx_data = 0;
        tx_data = 8'h00;
        tx_enable = 0;
        rxclk = 0;
        uld_rx_data = 0;
        rx_enable = 0;
        rx_in = 0;

        // Apply reset
        #10 reset = 0;

        // Test Case 1: Transmit and receive a single character
        reset = 1;
        #10 reset = 0;
        tx_enable = 1;
        ld_tx_data = 1;
        tx_data = 8'h41; // ASCII 'A'
        #10 ld_tx_data = 0;
        #100; // Wait for data reception
        assert(rx_data == 8'h41) else $display("Test Case 1 Failed!");

        // Test Case 2: Transmit and receive multiple characters
        reset = 1;
        #10 reset = 0;
        tx_enable = 1;
        ld_tx_data = 1;
        tx_data = 8'h48; // ASCII 'H'
        #10 ld_tx_data = 0;
        #10 tx_data = 8'h65; // ASCII 'e'
        #10 tx_data = 8'h6C; // ASCII 'l'
        #10 tx_data = 8'h6C; // ASCII 'l'
        #10 tx_data = 8'h6F; // ASCII 'o'
        #10 tx_enable = 0;
        #200; // Wait for data reception
        assert(rx_data == 8'h48) else $display("Test Case 2 Failed!");
        #10 assert(rx_data == 8'h65) else $display("Test Case 2 Failed!");
        #10 assert(rx_data == 8'h6C) else $display("Test Case 2 Failed!");
        #10 assert(rx_data == 8'h6C) else $display("Test Case 2 Failed!");
        #10 assert(rx_data == 8'h6F) else $display("Test Case 2 Failed!");

        // Test Case 3: Test frame error
        reset = 1;
        #10 reset = 0;
        tx_enable = 1;
        ld_tx_data = 1;
        tx_data = 8'h55; // Arbitrary data
        #10 ld_tx_data = 0;
        rx_in = 1; // Inject a framing error
        #100; // Wait for the error to propagate
        rx_in = 0;
        #100; // Wait for data reception
        assert(rx_frame_err == 1) else $display("Test Case 3 Failed!");

        // Test Case 4: Transmit and receive with frame error
        reset = 1;
        #10 reset = 0;
        tx_enable = 1;
        ld_tx_data = 1;
        tx_data = 8'h41; // ASCII 'A'
        #10 ld_tx_data = 0;
        #10 tx_data = 8'h42; // ASCII 'B' (frame error)
        #100; // Wait for data reception
        assert(rx_data == 8'h41) else $display("Test Case 4 Failed!");

        // Test Case 5: Transmit and receive with overrun error
        reset = 1;
        #10 reset = 0;
        tx_enable = 1;
        ld_tx_data = 1;
        tx_data = 8'h41; // ASCII 'A'
        #10 ld_tx_data = 0;
        #10 tx_data = 8'h42; // ASCII 'B'
        #10 tx_data = 8'h43; // ASCII 'C'
        #10 tx_data = 8'h44; // ASCII 'D'
        #10 tx_data = 8'h45; // ASCII 'E'
        #10 tx_data = 8'h46; // ASCII 'F' (overrun error)
        #200; // Wait for data reception
        assert(rx_over_run == 1) else $display("Test Case 5 Failed!");

        // End simulation
        $finish;
    end

    // Clock generation
    always #5 txclk = ~txclk;
    always #7 rxclk = ~rxclk;

endmodule
