`timescale 1ns / 1ps // Time unit: 1ns, Precision: 1ps

module Lab01_tb;

    //========================================================================
    // Signals declaration
    //========================================================================
    reg  i_sw1; // Test inputs (reg vì gán trong initial block)
    reg  i_sw2;
    reg  i_sw3;

    wire o_led1; // Outputs (wire vì nhận từ DUT)
    wire o_led2;
    wire o_led3;

    //========================================================================
    // Instantiate Device Under Test (DUT)
    //========================================================================
    Lab01 uut (
        .i_sw1(i_sw1),   // Connect test signal to DUT port
        .i_sw2(i_sw2),
        .i_sw3(i_sw3),
        .o_led1(o_led1),
        .o_led2(o_led2),
        .o_led3(o_led3)
    );

    //========================================================================
    // Stimulus generation
    //========================================================================
    initial begin
        // Display header
        $display("========================================");
        $display("   LAB01 SIMULATION TEST");
        $display("========================================");
        $display("Time | SW1 SW2 SW3 | LED1 LED2 LED3");
        $display("-----+-------------+---------------");

        // Test case 1: 000
        i_sw1 = 1'b0; i_sw2 = 1'b0; i_sw3 = 1'b0;
        #10;
        $display(" 10ns |  0   0   0 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 2: 001
        i_sw1 = 1'b0; i_sw2 = 1'b0; i_sw3 = 1'b1;
        #10;
        $display(" 20ns |  0   0   1 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 3: 010
        i_sw1 = 1'b0; i_sw2 = 1'b1; i_sw3 = 1'b0;
        #10;
        $display(" 30ns |  0   1   0 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 4: 011
        i_sw1 = 1'b0; i_sw2 = 1'b1; i_sw3 = 1'b1;
        #10;
        $display(" 40ns |  0   1   1 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 5: 100
        i_sw1 = 1'b1; i_sw2 = 1'b0; i_sw3 = 1'b0;
        #10;
        $display(" 50ns |  1   0   0 |  %b    %b    %b", o_led1, o_led2, o_led3);
        
        // Test case 6: 101
        i_sw1 = 1'b1; i_sw2 = 1'b0; i_sw3 = 1'b1;
        #10;
        $display(" 60ns |  1   0   1 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 7: 110
        i_sw1 = 1'b1; i_sw2 = 1'b1; i_sw3 = 1'b0;
        #10;
        $display(" 70ns |  1   1   0 |  %b    %b    %b", o_led1, o_led2, o_led3);

        // Test case 8: 111
        i_sw1 = 1'b1; i_sw2 = 1'b1; i_sw3 = 1'b1;
        #10;
        $display(" 80ns |  1   1   1 |  %b    %b    %b", o_led1, o_led2, o_led3);

        $display("========================================");
        $display("   SIMULATION COMPLETE");
        $display("========================================");

        // End simulation
        $finish;
    end
    
    //========================================================================
    // Monitor signals (optional - prints whenever signals change)
    //========================================================================
    initial begin
        $monitor("Time=%0t | SW=%b%b%b | LED=%b%b%b", 
                 $time, i_sw3, i_sw2, i_sw1, o_led3, o_led2, o_led1);
    end

    initial begin
        $dumpfile("Lab01_tb.vcd"); // Tên file sóng xuất ra
        $dumpvars(0, Lab01_tb);    // Lưu toàn bộ tín hiệu trong module Lab01_tb
    end

endmodule
