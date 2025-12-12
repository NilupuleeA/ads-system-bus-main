`timescale 1ns/1ps

module master_interface_tb();

    // ---------------------------------------------------------
    // Parameters
    // ---------------------------------------------------------
    localparam ADDR_WIDTH           = 16;
    localparam DATA_WIDTH           = 8;
    localparam SLAVE_MEM_ADDR_WIDTH = 12;

    // ---------------------------------------------------------
    // DUT I/O
    // ---------------------------------------------------------
    reg                     clk;
    reg                     rstn;

    reg  [DATA_WIDTH-1:0]   mwdata;
    reg  [ADDR_WIDTH-1:0]   maddr;
    reg                     mwvalid;
    wire [DATA_WIDTH-1:0]   mrdata;
    wire                    mrvalid;
    wire                    mready;
    reg                     wen;

    wire                    bwdata;
    wire                    brdata;
    wire                    bmode;
    wire                    bwvalid;
    reg                     brvalid;

    wire                    mbreq;
    reg                     mbgrant;
    reg                     msplit;

    reg                     ack;

    // ---------------------------------------------------------
    // Instantiate DUT
    // ---------------------------------------------------------
    master_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .mwdata(mwdata),
        .maddr(maddr),
        .mwvalid(mwvalid),
        .mrdata(mrdata),
        .mrvalid(mrvalid),
        .mready(mready),
        .wen(wen),

        .bwdata(bwdata),
        .brdata(brdata),
        .bmode(bmode),
        .bwvalid(bwvalid),
        .brvalid(brvalid),

        .mbreq(mbreq),
        .mbgrant(mbgrant),
        .msplit(msplit),

        .ack(ack)
    );

    // ---------------------------------------------------------
    // Clock
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // ---------------------------------------------------------
    // Task: apply reset
    // ---------------------------------------------------------
    task reset_dut();
    begin
        rstn = 0;
        mwdata = 0;
        maddr = 0;
        mwvalid = 0;
        wen = 0;
        brvalid = 0;
        mbgrant = 0;
        msplit = 0;
        ack = 0;
        #50;
        rstn = 1;
    end
    endtask

    // ---------------------------------------------------------
    // Task: Perform WRITE transaction
    // ---------------------------------------------------------
task write_transaction(input [ADDR_WIDTH-1:0] addr,
                       input [DATA_WIDTH-1:0] data);
    integer i;
begin
    // master sends address + write data to master interface
    @(posedge clk);
    maddr   <= addr;
    mwdata  <= data;
    wen     <= 1;       // write
    mwvalid <= 1;

    @(posedge clk);
    mwvalid <= 0;

    // wait until master interface requests bus
    wait (mbreq == 1);

    // grant the bus
    @(posedge clk);
    mbgrant <= 1;

    // --------------------------------------------------------
    // 1) SLAVE-DEVICE ADDRESS PHASE  (same as read)
    // --------------------------------------------------------
    wait (bwvalid == 1);     // master interface begins device address
    wait (bwvalid == 0);     // device address bits complete

    @(posedge clk);
    @(posedge clk);

    // ACK the slave-device address
    ack <= 1;
    @(posedge clk);
    ack <= 0;

    // --------------------------------------------------------
    // 2) SLAVE-MEMORY ADDRESS PHASE (same as read)
    // --------------------------------------------------------
    wait (bwvalid == 1);     // memory address bits start
    wait (bwvalid == 0);     // memory address bits complete

    @(posedge clk);
    @(posedge clk);

    // --------------------------------------------------------
    // 3) WRITE DATA PHASE (serial write)
    // --------------------------------------------------------
    // for (i = 0; i < DATA_WIDTH; i = i + 1) begin
    //     // during write, master interface drives b w data
    //     wait (bwvalid == 1);
    //     wait (bwvalid == 0);
    // end

    wait (bwvalid == 1);
    wait (bwvalid == 0);

    // release bus
    wait(mbreq == 0);                
    @(posedge clk);
    mbgrant <= 0;
    @(posedge clk);
end
endtask


    // ---------------------------------------------------------
    // Task: Perform READ transaction
    // ---------------------------------------------------------
    task read_transaction(input [ADDR_WIDTH-1:0] addr,
                          input [DATA_WIDTH-1:0] return_data);
    integer i;
        begin
            //master send data to the master interface
            @(posedge clk);                
            maddr                   = addr;
            wen                     <= 0;
            mwvalid                 <= 1;
            @(posedge clk);                 
            mwvalid                 <= 0;

            //wait until master interface requests the bus
            wait(mbreq == 1);               

            //grant the bus to the master interface
            @(posedge clk);                 
            mbgrant                 <= 1;

            //master interface start to send slave device address bits
            wait(bwvalid == 1);             
            wait(bwvalid == 0);             

            @(posedge clk);
            @(posedge clk);

            //send ack to the master interface
            ack                     <= 1;   
            @(posedge clk);
            ack                     <= 0;   

            //master interface start to send slave mem address bits
            wait(bwvalid == 1);             
            wait(bwvalid == 0);             

            @(posedge clk);
            @(posedge clk);
                                  
            //start to send data
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                brvalid <= 1;
                force dut.brdata = return_data[i];
                @(posedge clk);
                brvalid <= 0;
            end

            //low the bus grant signal
            wait(mbreq == 0);                
            @(posedge clk);
            mbgrant <= 0;
            @(posedge clk);

        end
    endtask


    task read_split_transaction(input [ADDR_WIDTH-1:0] addr,
                                input [DATA_WIDTH-1:0] return_data,
                                input integer split_delay_cycles); // delay before re-grant
        integer i;
        begin
            //master send data to the master interface
            @(posedge clk);
            maddr   <= addr;
            wen     <= 0;
            mwvalid <= 1;

            @(posedge clk);
            mwvalid <= 0;
            //wait until master interface requests the bus
            wait (mbreq == 1);

            //grant the bus to the master interface
            @(posedge clk);
            mbgrant <= 1;

            //master interface start to send slave device address bits
            wait (bwvalid == 1);
            wait (bwvalid == 0);

            @(posedge clk);
            @(posedge clk);

            //send ack to the master interface
            ack <= 1;
            @(posedge clk);
            ack <= 0;

            //master interface start to send slave mem address bits
            wait (bwvalid == 1);
            wait (bwvalid == 0);

            @(posedge clk);
            @(posedge clk);

            //slave send split signal and low the bus grate signal to the master interface
            @(posedge clk);
            msplit <= 1;  
            mbgrant <= 0;

            //wait for some cycles before re-granting the bus to the master interface
            repeat (split_delay_cycles) @(posedge clk);

            @(posedge clk);
            msplit  <= 0;

            @(posedge clk);
            mbgrant <= 1;  

            //start to send data again after the split
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                brvalid <= 1;
                force dut.brdata = return_data[i];
                @(posedge clk);
                brvalid <= 0;
            end

            //low the bus grant signal
            mbgrant <= 0;
            @(posedge clk);
        end
    endtask


    initial begin
        reset_dut();

        #20;

        // Perform a write transaction
        //write_transaction(16'h32A5, 8'h3C);
        // addr: 0011 0010 1010 0101     
        // data: 0011 1100  
        #40;


        // Perform a read transaction returning data 0x96
        write_transaction(16'h32A5, 8'hA3);

        write_transaction(16'h3AAA, 8'h96);
        //address 0011 0010 1010 0101
        //data to return 1001 0110

        #2000;

        $display("Simulation completed.");
        $finish;
    end

endmodule
