// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

`define BIT4 1'b0
`define BIT2 1'b1
`define WS 1'b0
`define OS 1'b1

module core_tb_p3;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;   // kernel = 3 x 3
parameter len_onij = 16; // output image = 4 x 4
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;  // input image = 6 x 6
parameter len_kij_sqrt = 3;
parameter len_onij_sqrt = 4;

reg clk = 0;
reg reset = 1;

wire [49:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;  // Memory Data
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;          // Memory Address
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;          // Memory Address for Accumulation
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;
reg relu_q = 0;
reg [31:0] D_wmem_q = 0;
reg [31:0] D_wmem = 0;
reg CEN_wmem_q = 1;
reg CEN_wmem = 1;
reg WEN_wmem_q = 1;
reg WEN_wmem = 1;
reg [10:0] A_wmem   = 0;
reg [10:0] A_wmem_q = 0;
reg flush_q=0;
reg flush =0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;

reg relu;
reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

reg [31:0] D_2D [63:0];
reg [1:0] mode = 0;
reg debug_flag = 0;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer w0_file, w1_file, w2_file, w3_file, w4_file, w5_file, w6_file, w7_file, w8_file;
integer y_file;
integer out_head;
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij, ic, t_ic, t_kij;
integer error;

assign inst_q[49] = flush_q;
assign inst_q[48] = CEN_wmem_q;
assign inst_q[47] = WEN_wmem_q;
assign inst_q[46:36] = A_wmem_q;
assign inst_q[35] = 1'b1; // this is for sel mode,, 1'b0: weight stationary, 1'b1: output stationary
assign inst_q[34] = relu_q;
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
  	.D_xmem(D_xmem_q), 
  	.sfp_out(sfp_out), 
  	//.mode(mode),
	.reset(reset),
	.D_wmem(D_wmem_q)); 


initial begin
  $dumpfile("core_tb_p3.vcd");
  $dumpvars(0,core_tb_p3);

  // OS
  mode = {`OS, `BIT4};

  // modify input to output stationary
  generate_modified_acti("../datafiles/activation.txt", "../datafiles/modi_acti.txt");
  transpose_weight("../datafiles/weight_kij0.txt", "../datafiles/os_wei_kij0.txt");
  transpose_weight("../datafiles/weight_kij1.txt", "../datafiles/os_wei_kij1.txt");
  transpose_weight("../datafiles/weight_kij2.txt", "../datafiles/os_wei_kij2.txt");
  transpose_weight("../datafiles/weight_kij3.txt", "../datafiles/os_wei_kij3.txt");
  transpose_weight("../datafiles/weight_kij4.txt", "../datafiles/os_wei_kij4.txt");
  transpose_weight("../datafiles/weight_kij5.txt", "../datafiles/os_wei_kij5.txt");
  transpose_weight("../datafiles/weight_kij6.txt", "../datafiles/os_wei_kij6.txt");
  transpose_weight("../datafiles/weight_kij7.txt", "../datafiles/os_wei_kij7.txt");
  transpose_weight("../datafiles/weight_kij8.txt", "../datafiles/os_wei_kij8.txt");

  // start execution
  reset_hardware();
  $display("Part 3: Output stationary");
  run_sim("../datafiles/modi_acti.txt", "../datafiles/os_wei", "../datafiles/output.txt");

  #10 $finish;
end

// re-order part_1 acti format to part_3 acti format
task generate_modified_acti;
	input [8*30:1] input_file;
	input [8*30:1] output_file;

	reg [31:0] ori_in [0:35];
	reg [3:0] temp_tt [0:8];

	begin
	// read original data
	x_file = $fopen(input_file, "r");
	x_scan_file = $fscanf(x_file,"%s", captured_data);
	x_scan_file = $fscanf(x_file,"%s", captured_data);
	x_scan_file = $fscanf(x_file,"%s", captured_data);
	for (i=0; i<6*6; i=i+1) begin
		x_scan_file = $fscanf(x_file, "%32b", ori_in[i]);
	end
	$fclose(x_file);

	// make target modified activation txt file
	// generate one by one..
	y_file = $fopen(output_file, "w");
	if (y_file == 0) $display("open fail");
	for (ic=0; ic<8; ic=ic+1) begin: loop1
		for (kij=0; kij<9; kij=kij+1) begin: loop2
			// for first line
			temp_tt[0] = ori_in[6*(kij/3)+kij%3  ][bw*ic +: bw];
			temp_tt[1] = ori_in[6*(kij/3)+kij%3+1][bw*ic +: bw];
			temp_tt[2] = ori_in[6*(kij/3)+kij%3+2][bw*ic +: bw];
			temp_tt[3] = ori_in[6*(kij/3)+kij%3+3][bw*ic +: bw];

			// for second line
			temp_tt[4] = ori_in[6*(kij/3)+kij%3+6][bw*ic +: bw];
			temp_tt[5] = ori_in[6*(kij/3)+kij%3+7][bw*ic +: bw];
			temp_tt[6] = ori_in[6*(kij/3)+kij%3+8][bw*ic +: bw];
			temp_tt[7] = ori_in[6*(kij/3)+kij%3+9][bw*ic +: bw];

			// write concatenated data to output txt
			$fdisplay(y_file, "%32b", {temp_tt[7], temp_tt[6], temp_tt[5], temp_tt[4], temp_tt[3], temp_tt[2], temp_tt[1], temp_tt[0]});
		end
	end
	$fclose(y_file);

	end
endtask

task transpose_weight;
	input [8*30:1] input_file;
	input [8*30:1] output_file;

	reg [31:0] ori_in [0:7];
	reg [ 3:0] ori_mat [0:7][0:7];
	reg [ 3:0] temp [0:7];

	begin
		// read input file
		x_file = $fopen(input_file, "r");
    		x_scan_file = $fscanf(x_file,"%s", captured_data);
    		x_scan_file = $fscanf(x_file,"%s", captured_data);
    		x_scan_file = $fscanf(x_file,"%s", captured_data);
		for (i=0; i<8; i=i+1) begin
			x_scan_file = $fscanf(x_file, "%32b", ori_in[i]);
		end
		for (i=0; i<8; i=i+1) begin
			for (j=0; j<8; j=j+1) begin
				ori_mat[i][j] = ori_in[i][4*j +: 4];
			end
		end
		$fclose(x_file);

		// transpose and save
		y_file = $fopen(output_file, "w");
		for (i=0; i<8; i=i+1) begin
			for (j=0; j<8; j=j+1) begin
				temp[j] = ori_mat[j][i];
			end
			$fdisplay(y_file, "%32b", {temp[7], temp[6], temp[5], temp[4], temp[3], temp[2], temp[1], temp[0]});
		end
		$fclose(y_file);
	end
endtask




task reset_hardware;
  begin
    //////// Reset /////////
    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
    /////////////////////////
  end
endtask

task run_sim;
  input [8*30:1] act_file;
  input [8*30:1] wgt_file;
  input [8*30:1] out_file;

  begin
  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;
  relu     = 0;
  debug_flag = 0;

  //x_file = $fopen("activation_tile0.txt", "r");
  x_file = $fopen(act_file, "r");

  /////// Activation data writing to memory ///////
  for (t=0; t<72; t=t+1) begin  
    #0.5 clk = 1'b0;  
    x_scan_file = $fscanf(x_file,"%32b", D_xmem); 
    WEN_xmem = 0; CEN_xmem = 0; 
    if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////




  //////////////////////////////////////////////////////
  // WRITE kernel data to memory
  // in output stationary, we don't need kij for loop
  w_file_name = {wgt_file, "_kij0.txt"};
  w0_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij1.txt"};
  w1_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij2.txt"};
  w2_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij3.txt"};
  w3_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij4.txt"};
  w4_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij5.txt"};
  w5_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij6.txt"};
  w6_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij7.txt"};
  w7_file = $fopen(w_file_name, "r");
  w_file_name = {wgt_file, "_kij8.txt"};
  w8_file = $fopen(w_file_name, "r");


    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   

    A_wmem = 11'b00000000000;
    for (t_ic=0; t_ic<8; t_ic = t_ic + 1) begin
	// kij=0
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w0_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        if (t_ic>0) A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=1
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w1_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=2
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w2_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  
	
	// kij=3
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w3_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=4
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w4_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=5
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w5_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=6
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w6_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1; 

	// kij=7
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w7_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

	// kij=8
        #0.5 clk = 1'b0;  
        w_scan_file = $fscanf(w8_file,"%32b", D_wmem); 
        WEN_wmem = 0; CEN_wmem = 0; 
        A_wmem = A_wmem + 1; 
        #0.5 clk = 1'b1;  

    end

    #0.5 clk = 1'b0;  WEN_wmem = 1;  CEN_wmem = 1; A_wmem = 0;
    #0.5 clk = 1'b1; 

    $fclose(w0_file);
    $fclose(w1_file);
    $fclose(w2_file);
    $fclose(w3_file);
    $fclose(w4_file);
    $fclose(w5_file);
    $fclose(w6_file);
    $fclose(w7_file);
    $fclose(w8_file);
    /////////////////////////////////////


    /////// Activation data writing to L0 ///////
    #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0; 
    #0.5 clk = 1'b1;
    for (t=0; t<72; t=t+1) begin  
      #0.5 clk = 1'b0;  
      l0_wr = 1;
      A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0;  
    l0_wr = 0;
    WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////


    //////// Weight data writing to IFIFO /////
    #0.5 clk = 1'b0; WEN_wmem = 1; CEN_wmem = 0; 
    #0.5 clk = 1'b1;
    for (t=0; t<72; t=t+1) begin  
      #0.5 clk = 1'b0;  
      ififo_wr = 1;
      A_wmem = A_wmem + 1;
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0;  
    ififo_wr = 0;
    WEN_wmem = 1;  CEN_wmem = 1; A_wmem = 0;
    #0.5 clk = 1'b1; 
    //////////////////////////////////////////




    /////// Execution ///////
    for (t=0; t<(72+row+col); t=t+1) begin  
      #0.5 clk = 1'b0;
      if(t >= 72)begin
        execute = 0;
        l0_rd = 0;
        ififo_rd = 0;
      end
      else begin
        execute = 1;
        l0_rd = 1;
        ififo_rd = 1;
      end
      
      #0.5 clk = 1'b1;

    end
      #0.5 clk = 1'b0;
      execute = 0;
      //l0_rd = 1;
      //ififo_rd = 1;
      //load = 0;
      #0.5 clk = 1'b1;
    /////////////////////////////////////


    ////////// FLUSH ALL PSUM TO SFU & compare results /////
    #0.5 clk=1'b0; flush = 1; relu = 1;

    #0.5 clk=1'b1;
    #0.5 clk=1'b0; // wait for some time
    #0.5 clk=1'b1;
    #0.5 clk=1'b0; // wait for some time


    out_head = $fopen(out_file, "r");
    out_scan_file = $fscanf(out_head,"%s", captured_data);
    out_scan_file = $fscanf(out_head,"%s", captured_data);
    out_scan_file = $fscanf(out_head,"%s", captured_data);
    error = 0;
    for (i=0; i<8; i=i+1) begin
       debug_flag = 1'b1;
       out_scan_file = $fscanf(out_head, "%128b", answer); // reading from out file to answer
       if (sfp_out == answer)
          $display("%2d-th output featuremap Data matched! :D", i); 
       else begin
          $display("%2d-th output featuremap Data ERROR!!", i); 
          $display("sfpout: %128b", sfp_out);
          $display("answer: %128b", answer);
          error = 1;
       end

       #0.5 clk=1'b1;
       #0.5 clk=1'b0;
    end
    debug_flag = 1'b0;
    $fclose(out_head);

    if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 
    end

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  //#10 $finish;
  end
endtask

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
   relu_q     <= relu;
   D_wmem_q   <= D_wmem;
   CEN_wmem_q <= CEN_wmem;
   WEN_wmem_q <= WEN_wmem;
   A_wmem_q   <= A_wmem;
   flush_q <= flush;
end


endmodule




