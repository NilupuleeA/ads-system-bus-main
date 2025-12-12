module switch_to_led(
    input  wire [2:0] SW,   // 18 switches on DE2-115
    output wire [2:0] LED   // 18 LEDs on DE2-115
);

    // Direct mapping: each switch controls corresponding LED
    assign LED = SW;

endmodule