// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

`define BIT4 0
`define BIT2 1

module core_tb;

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

wire [34:0] inst_q; 

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

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;

reg [63:0] D_xmem_tmp;
reg [bw*row-1:0] D_xmem_even;
reg [bw*row-1:0] D_xmem_odd;
reg [bw*row-1:0] D_xmem_even_q;
reg [bw*row-1:0] D_xmem_odd_q;

reg [63:0] line64;
reg [3:0] nibble;
integer e = 0;
integer o = 0;


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
reg [8*300:1] w_file_name;
reg [8*300:1] w_file_name2;

wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

reg [31:0] D_2D [63:0];
reg mode_q;

reg [10:0] A_pmem_tmp = 0;
integer tile_idx, file_idx;

integer x_file, x_scan_file, x_file2, x_scan_file2 ; // file_handler
integer w_file, w_scan_file, w_file2, w_scan_file2 ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file, out_file2, out_scan_file2 ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

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

      .D_xmem_even(D_xmem_even_q), // 2bit
      .D_xmem_odd(D_xmem_odd_q), // 2bit
    
      .sfp_out(sfp_out), 
      .reset(reset),
      .mode(mode_q)
    );

initial begin
  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  reset_hardware();
  $display("Part 2: test 4bit");
  mode_q = 0;
  run_sim_4bit("txt_files/activation.txt", "txt_files/weight", "txt_files/output.txt");

  #30
  reset_hardware();
  $display("Part 2: test 2bit");
  mode_q = 1;
  run_sim_2bit_test("txt_files_test/activation.txt", "txt_files_test/weight", "txt_files_test/output.txt");
  $finish;
end

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

task run_sim_4bit;
  input [8*30:1] act_file; // txt_files/activation.txt
  input [8*30:1] wgt_file; // txt_files/weight
  input [8*30:1] out_file; // txt_files/output.txt
  begin
  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1; // memory is off
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

  //x_file = $fopen("activation_tile0.txt", "r");
  x_file = $fopen(act_file, "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);



  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  
    x_scan_file = $fscanf(x_file,"%32b", D_xmem); 
    WEN_xmem = 0; CEN_xmem = 0; // Memory write
    if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = {wgt_file, "_kij0.txt"};
     1: w_file_name = {wgt_file, "_kij1.txt"};
     2: w_file_name = {wgt_file, "_kij2.txt"};
     3: w_file_name = {wgt_file, "_kij3.txt"};
     4: w_file_name = {wgt_file, "_kij4.txt"};
     5: w_file_name = {wgt_file, "_kij5.txt"};
     6: w_file_name = {wgt_file, "_kij6.txt"};
     7: w_file_name = {wgt_file, "_kij7.txt"};
     8: w_file_name = {wgt_file, "_kij8.txt"};
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

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





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  
      w_scan_file = $fscanf(w_file,"%32b", D_xmem); 
      WEN_xmem = 0; CEN_xmem = 0; 
      if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel data writing to L0 ///////
    A_xmem = 11'b10000000000;
    #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0; 
    #0.5 clk = 1'b1;
    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  
      l0_wr = 1; 
      A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0;  
    WEN_xmem = 1;  CEN_xmem = 1;
    l0_wr = 0; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////
    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  
      l0_rd = 1; 
      load = 1; 
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0;  l0_rd = 0; load = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0; 
    #0.5 clk = 1'b1;
    for (t=0; t<len_nij; t=t+1) begin  
      #0.5 clk = 1'b0;  
      l0_wr = 1;
      A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0;  l0_wr = 0; WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Execution ///////
    for (t=0; t<(len_nij+row+col); t=t+1) begin  
      #0.5 clk = 1'b0;
      if(t >= len_nij)begin
        execute = 0;
        l0_rd = 0;
      end
      else begin
        execute = 1;
        l0_rd = 1; 
      end
      
      #0.5 clk = 1'b1;

    end
      #0.5 clk = 1'b0;
      execute = 0;
      l0_rd = 0;
      load = 0;
      #0.5 clk = 1'b1;
    /////////////////////////////////////



    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
    #0.5 clk = 1'b0;  
    ofifo_rd = 1;
    #0.5 clk = 1'b1;   

    if(ofifo_valid) begin
      for(t=0; t<len_nij + 1; t=t+1) begin
        #0.5 clk = 1'b0;  
        
        WEN_pmem = 0; CEN_pmem = 0; 
        if (t>0) A_pmem = A_pmem + 1; 
        #0.5 clk = 1'b1;          
      end
    end

    #0.5 clk = 1'b0;  
    WEN_pmem = 1;  CEN_pmem = 1;
    ofifo_rd = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////


  end  // end of kij loop


  ////////// Accumulation /////////
  //out_file = $fopen("out.txt", "r");  
  out_file = $fopen(out_file, "r");  
  //acc_file = $fopen("txt_files/acc_address.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; relu = 0;
    #0.5 clk = 1'b1; 

    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (sfp_out == answer)begin
         $display("%2d-th output featuremap Data matched! :D", i);
      end
       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", sfp_out);
         $display("answer: %128b", answer);
         error = 1;
       end
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  
    A_pmem = 0;
    A_pmem_tmp = 0;

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   

        if (j<len_kij) begin
          CEN_pmem = 0; WEN_pmem = 1; 
          case((j / len_kij_sqrt) % len_kij_sqrt)
            0: A_pmem = (11'd0 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt); // 0, 114, 228
            1: A_pmem = (11'd114 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
            2: A_pmem = (11'd228 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
          endcase
          //acc_scan_file = $fscanf(acc_file, "%11b", A_pmem_tmp);
          //if(A_pmem != A_pmem_tmp) $display("%11b, %11b", A_pmem, A_pmem_tmp);
        end else begin
          CEN_pmem = 1; WEN_pmem = 1;
        end
        if (j>0)  acc = 1; 
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0; relu = 1;
    #0.5 clk = 1'b1; 
  end
  relu = 0;

  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  //#10 $finish;
  end
endtask

task run_sim_2bit_test;
  input [8*300:1] act_file2;
  input [8*300:1] wgt_file2;
  input [8*300:1] out_file2;
  begin
    inst_w   = 0; 
    D_xmem   = 0;
    CEN_xmem = 1;
    WEN_xmem = 1;
    A_xmem   = 0;
    A_pmem = 0;
    ofifo_rd = 0;
    ififo_wr = 0;
    ififo_rd = 0;
    l0_rd    = 0;
    l0_wr    = 0;
    execute  = 0;
    load     = 0;
    relu     = 0;

    x_file2 = $fopen(act_file2, "r");
    x_scan_file2 = $fscanf(x_file2,"%s", captured_data);
    x_scan_file2 = $fscanf(x_file2,"%s", captured_data);
    x_scan_file2 = $fscanf(x_file2,"%s", captured_data);

    for (t=0; t<len_nij; t=t+1) begin  
      #0.5 clk = 1'b0;  
      x_scan_file2 = $fscanf(x_file2,"%32b", D_xmem); 
      WEN_xmem = 0; 
      CEN_xmem = 0; 
      if (t>0) A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0;  
    WEN_xmem = 1;  
    CEN_xmem = 1; 
    A_xmem   = 0;
    #0.5 clk = 1'b1; 

    $fclose(x_file2);
    tile_idx=0;
    //for (tile_idx = 0; tile_idx < 2; tile_idx = tile_idx + 1) begin  // two OC tiles
      
      for (kij=0; kij<9; kij=kij+1) begin  // kij loop (0..8)
        //$display("tile = %d, kij = %d", tile_idx, kij);
        file_idx = tile_idx*9 + kij;
        case(file_idx)
          0 : w_file_name2 = {wgt_file2, "_kij0.txt"};
          1 : w_file_name2 = {wgt_file2, "_kij1.txt"};
          2 : w_file_name2 = {wgt_file2, "_kij2.txt"};
          3 : w_file_name2 = {wgt_file2, "_kij3.txt"};
          4 : w_file_name2 = {wgt_file2, "_kij4.txt"};
          5 : w_file_name2 = {wgt_file2, "_kij5.txt"};
          6 : w_file_name2 = {wgt_file2, "_kij6.txt"};
          7 : w_file_name2 = {wgt_file2, "_kij7.txt"};
          8 : w_file_name2 = {wgt_file2, "_kij8.txt"};
          9 : w_file_name2 = {wgt_file2, "_kij9.txt"};
          10: w_file_name2 = {wgt_file2, "_kij10.txt"};
          11: w_file_name2 = {wgt_file2, "_kij11.txt"};
          12: w_file_name2 = {wgt_file2, "_kij12.txt"};
          13: w_file_name2 = {wgt_file2, "_kij13.txt"};
          14: w_file_name2 = {wgt_file2, "_kij14.txt"};
          15: w_file_name2 = {wgt_file2, "_kij15.txt"};
          16: w_file_name2 = {wgt_file2, "_kij16.txt"};
          17: w_file_name2 = {wgt_file2, "_kij17.txt"};
        endcase

        w_file2 = $fopen(w_file_name2, "r");
        w_scan_file2 = $fscanf(w_file2,"%s", captured_data);
        w_scan_file2 = $fscanf(w_file2,"%s", captured_data);
        w_scan_file2 = $fscanf(w_file2,"%s", captured_data);

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

        A_xmem = 11'b10000000000;

        for (t=0; t<col; t=t+1) begin  
          #0.5 clk = 1'b0; 

          // read one 64-bit line from weight file
          w_scan_file2 = $fscanf(w_file2,"%64b", line64);

          D_xmem_even = 32'b0;
          D_xmem_odd  = 32'b0;
          e = 0;
          o = 0;

          // build even/odd 32-bit words
          for (i = 0; i < 16; i = i + 1) begin
            nibble = (line64 >> (4*(15 - i))) & 4'hF;
            if ((i % 2) == 0) begin
              D_xmem_even = {D_xmem_even[27:0], nibble};
              e = e + 1;
            end else begin
              D_xmem_odd  = {D_xmem_odd[27:0],  nibble};
              o = o + 1;
            end
          end
          //$display("d_even wr[%d] [%d] = %b",kij, t, D_xmem_even);
          //$display("d_odd wr[%d] [%d]= %b",kij, t, D_xmem_odd); // verified works.

          // write EVEN word
          D_xmem   = D_xmem_even;
          WEN_xmem = 0; 
          CEN_xmem = 0;
          #0.5 clk = 1'b1;  // write
          #0.5 clk = 1'b0;  
          A_xmem   = A_xmem + 1;

          // write ODD word (next address)
          D_xmem   = D_xmem_odd;
          #0.5 clk = 1'b1;  // write
          #0.5 clk = 1'b0;  
          A_xmem = A_xmem + 1;

        end

        #0.5 clk = 1'b0;  
        WEN_xmem = 1;  
        CEN_xmem = 1; 
        A_xmem   = 0;
        #0.5 clk = 1'b1; 

        $fclose(w_file2);


        // Kernel data writing to L0
        A_xmem = 11'b10000000000;
        #0.5 clk = 1'b0; 
        WEN_xmem = 1; //read
        CEN_xmem = 0;
        #0.5 clk = 1'b1;

        for (t=0; t<2*col; t=t+1) begin  
          #0.5 clk = 1'b0;  
          l0_wr  = 1; 
          A_xmem = A_xmem + 1;
          #0.5 clk = 1'b1;
        end

        #0.5 clk = 1'b0;  
        l0_wr    = 0;
        WEN_xmem = 1;  
        CEN_xmem = 1; 
        A_xmem   = 0;
        #0.5 clk = 1'b1; 

        // Kernel loading to PEs
        // 2*col cycles so each MAC_TILE sees:
        //   first weight  -> b_even
        //   second weight -> b_odd
        for (t=0; t<2*col; t=t+1) begin  
          #0.5 clk = 1'b0;  
          l0_rd = 1; 
          load  = 1; 
          #0.5 clk = 1'b1;
        end

        #0.5 clk = 1'b0;  
        l0_rd = 0; 
        load  = 0;
        #0.5 clk = 1'b1; 

        // small gap
        #0.5 clk = 1'b0;  
        load  = 0; 
        l0_rd = 0;
        #0.5 clk = 1'b1;  
        for (i=0; i<10 ; i=i+1) begin
          #0.5 clk = 1'b0;
          #0.5 clk = 1'b1;  
        end

        // Activation data writing to L0

        #0.5 clk = 1'b0; 
        WEN_xmem = 1; 
        CEN_xmem = 0; 
        #0.5 clk = 1'b1;
        for (t=0; t<len_nij; t=t+1) begin  
          #0.5 clk = 1'b0;  
          l0_wr  = 1;
          A_xmem = A_xmem + 1;
          #0.5 clk = 1'b1;
        end

        #0.5 clk = 1'b0;  
        l0_wr    = 0; 
        WEN_xmem = 1;  
        CEN_xmem = 1; 
        A_xmem   = 0;
        #0.5 clk = 1'b1; 

        // Execution (same structure)
        for (t=0; t<(len_nij+row+col); t=t+1) begin  
          #0.5 clk = 1'b0;
          if(t >= len_nij) begin
            execute = 0;
            l0_rd   = 0;
          end else begin
            execute = 1;
            l0_rd   = 1; 
          end
          #0.5 clk = 1'b1;
        end

        #0.5 clk = 1'b0;
        execute = 0;
        l0_rd   = 0;
        load    = 0;
        #0.5 clk = 1'b1;

        // OFIFO read -> PMEM (same as 4-bit)
        #0.5 clk = 1'b0;  
        ofifo_rd = 1;
        #0.5 clk = 1'b1;   

        if(ofifo_valid) begin
          for(t=0; t<len_nij + 1; t=t+1) begin
            #0.5 clk = 1'b0;  
            WEN_pmem = 0; 
            CEN_pmem = 0; 
            if (t>0) A_pmem = A_pmem + 1; 
            #0.5 clk = 1'b1;          
          end
        end

        #0.5 clk = 1'b0;  
        WEN_pmem = 1;  
        CEN_pmem = 1;
        ofifo_rd = 0;
        #0.5 clk = 1'b1; 

      end // kij loop
    //end   // tile loop

    //Accumulation + comparison

    // Open golden output
    out_file2 = $fopen(out_file2, "r");
    out_scan_file2 = $fscanf(out_file2,"%s", answer); 
    out_scan_file2 = $fscanf(out_file2,"%s", answer); 
    out_scan_file2 = $fscanf(out_file2,"%s", answer); 

    error = 0;
    $display("############ Verification Start during accumulation #############"); 

      for (i=0; i<len_onij+1; i=i+1) begin 

        #0.5 clk = 1'b0; relu = 0;
        #0.5 clk = 1'b1; 

        if (i>0) begin
        out_scan_file2 = $fscanf(out_file2,"%128b", answer); // reading from out file to answer
          if (sfp_out == answer)begin
            $display("%2d-th output featuremap Data matched! :D", i);
          end
          else begin
            $display("%2d-th output featuremap Data ERROR!!", i); 
            $display("sfpout: %128b", sfp_out);
            $display("answer: %128b", answer);
            error = 1;
          end
        end
      
    
        #0.5 clk = 1'b0; reset = 1;
        #0.5 clk = 1'b1;  
        #0.5 clk = 1'b0; reset = 0; 
        #0.5 clk = 1'b1;  
        A_pmem = 0;
        A_pmem_tmp = 0;

        for (j=0; j<len_kij+1; j=j+1) begin 

          #0.5 clk = 1'b0;   

            if (j<len_kij) begin
              CEN_pmem = 0; WEN_pmem = 1; 
              case((j / len_kij_sqrt) % len_kij_sqrt)
                0: A_pmem = (11'd0 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt); // 0, 114, 228
                1: A_pmem = (11'd114 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
                2: A_pmem = (11'd228 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
              endcase
              //acc_scan_file = $fscanf(acc_file, "%11b", A_pmem_tmp);
              //if(A_pmem != A_pmem_tmp) $display("%11b, %11b", A_pmem, A_pmem_tmp);
            end else begin
              CEN_pmem = 1; WEN_pmem = 1;
            end
            if (j>0)  acc = 1; 
          #0.5 clk = 1'b1;   
        end

        #0.5 clk = 1'b0; acc = 0; relu = 1;
        #0.5 clk = 1'b1; 
      end
      relu = 0;

      if (error == 0) begin
        $display("############ No error detected ##############"); 
        $display("########### Project Completed !! ############"); 

      end

      //fclose(acc_file2);

    for (t=0; t<10; t=t+1) begin  
      #0.5 clk = 1'b0;  
      #0.5 clk = 1'b1;  
    end
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

   //mode_q <= mode_q;
   D_xmem_even_q <= D_xmem_even;
   D_xmem_odd_q <= D_xmem_odd;
end


endmodule