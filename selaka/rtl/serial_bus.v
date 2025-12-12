module serial_bus #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 8,
    parameter SLAVE_MEM_ADDR_WIDTH = 12
)
(   
    input               clk,
    input               rstn,
    output              bus_busy,

    // Master_1 
    input               m1_wdata,                     
    output              m1_rdata,
    input               m1_mode,                      
    input               m1_wvalid,                    
    output              m1_rvalid,                    
    input               m1_breq,
	output              m1_bgrant,
	output              m1_split,
	output              m1_ack,

    // Master_2 
    input               m2_wdata,                     
    output              m2_rdata,
    input               m2_mode,                      
    input               m2_wvalid,                    
    output              m2_rvalid,                    
    input               m2_breq,
	output              m2_bgrant,
	output              m2_split,
	output              m2_ack,

    // Slave 1 
    output              s1_wdata,                     
    input               s1_rdata,
    output              s1_mode,                      
    output              s1_wvalid,                    
    input               s1_rvalid,
    input               s1_ready,

    // Slave 2 
    output              s2_wdata,                     
    input               s2_rdata,
    output              s2_mode,                      
    output              s2_wvalid,                    
    input               s2_rvalid,
    input               s2_ready,

    // Slave 3 with split support 
    output              s3_wdata,                     
    input               s3_rdata,
    output              s3_mode,                      
    output              s3_wvalid,                    
    input               s3_rvalid,
    input               s3_ready,
    input               s3_split,
    output              s3_split_grant,
	 output reg [7:0] bus_led
);



wire                    msel;
wire                    m_mode;
wire                    m_wvalid;
wire                    m_wdata;
wire [1:0]              ssel;
wire                    m_ack;
wire [2:0]              s_wvalid;
wire                    s_rdata;
wire                    s_rvalid;

assign m1_ack           = m_ack;
assign m2_ack           = m_ack;
assign s1_wvalid        = s_wvalid[0];
assign s2_wvalid        = s_wvalid[1];
assign s3_wvalid        = s_wvalid[2];
assign m1_rdata         = s_rdata;
assign m2_rdata         = s_rdata;
assign m1_rvalid        = s_rvalid;
assign m2_rvalid        = s_rvalid;

assign s1_mode          = m_mode;
assign s2_mode          = m_mode;
assign s3_mode          = m_mode;
assign s1_wdata         = m_wdata;
assign s2_wdata         = m_wdata;
assign s3_wdata         = m_wdata;

assign bus_busy         = (s1_ready & s2_ready & s3_ready) ? 1'b0 : 1'b1;



	 always @(posedge clk) begin
		 if(!rstn) begin
			bus_led <= 8'b10100000;
		 end
		 else begin
			if(m1_rvalid) bus_led <= 8'b00011101;
		 end
	 end



arbiter arbiter_inst (
    .clk                (clk),
    .rstn               (rstn),
    .breq1              (m1_breq),
    .breq2              (m2_breq),
    .sready1            (s1_ready),
    .sready2            (s2_ready),
    .sreadysp           (s3_ready),
    .ssplit             (s3_split),
    .bgrant1            (m1_bgrant),
    .bgrant2            (m2_bgrant),
    .msel               (msel),
    .msplit1            (m1_split),
    .msplit2            (m2_split),
    .split_grant        (s3_split_grant)
);

addr_dec addr_decoder(
    .clk                (clk),
    .rstn               (rstn),
    .addr_valid         (m_wvalid),           
    .addr_data          (m_wdata),            
    .sready             ({s3_ready, s2_ready, s1_ready}),
    .split              (s3_split),                
    .split_grant        (s3_split_grant),          
    .ssel               (ssel),
    .ack                (m_ack),              
    .mvalid             (s_wvalid)
);

// Write data mux
mux2 #(.DATA_WIDTH(1)) wdata_mux (
    .dsel               (msel),
    .d0                 (m1_wdata),
    .d1                 (m2_wdata),
    .dout               (m_wdata)
);

// Master control muxes
mux2 #(.DATA_WIDTH(2)) mctrl_mux ( 
    .dsel               (msel),
    .d0                 ({m1_mode, m1_wvalid}),
    .d1                 ({m2_mode, m2_wvalid}),
    .dout               ({m_mode, m_wvalid})
);

// Read data mux
mux3 #(.DATA_WIDTH(1)) rdata_mux (
    .dsel               (ssel),
    .d0                 (s1_rdata),
    .d1                 (s2_rdata),
    .d2                 (s3_rdata),
    .dout               (s_rdata)
);

// Read control mux
mux3 #(.DATA_WIDTH(1)) rctrl_mux (
    .dsel               (ssel),
    .d0                 (s1_rvalid),
    .d1                 (s2_rvalid),
    .d2                 (s3_rvalid),
    .dout               (s_rvalid)
);

endmodule

