//======================================================================
// Module: lab01
// Description: Wiring 3 switches to 3 LEDs (direct connection)
// Target Device: GW5A-LV25UG324C2/I1
// Board: Xiaomeige ACG525
//======================================================================

module Lab01 (
    input  wire i_sw1,    // Switch 1 input
    input  wire i_sw2,    // Switch 2 input
    input  wire i_sw3,    // Switch 3 input
    
    output wire o_led1,   // LED 1 output
    output wire o_led2,   // LED 2 output
    output wire o_led3    // LED 3 output
);

    //======================================================================
    // Combinational Logic: Direct connection
    // LED follows switch state immediately
    //======================================================================

    assign o_led1 = i_sw1;  // SW1 -> LED1
    assign o_led2 = i_sw2;  // SW2 -> LED2
    assign o_led3 = i_sw3;  // SW3 -> LED3

endmodule