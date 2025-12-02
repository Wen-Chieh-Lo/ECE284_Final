task run_sim_2bit;
  input [8*30:1] act_file; // e.g. "txt_2bit/activation.txt"
  input [8*30:1] wgt_file; // e.g. "txt_2bit/weight"
  input [8*30:1] out_file; // e.g. "txt_2bit/output.txt"
  begin
    // -------------------------------------------------
    // Common init (same style as run_sim)
    // -------------------------------------------------
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

    // -------------------------------------
    // 1) Write activations into XMEM (same as 4-bit)
    // -------------------------------------
    x_file = $fopen(act_file, "r");
    x_scan_file = $fscanf(x_file,"%s", captured_data);
    x_scan_file = $fscanf(x_file,"%s", captured_data);
    x_scan_file = $fscanf(x_file,"%s", captured_data);

    for (t=0; t<len_nij; t=t+1) begin  
      #0.5 clk = 1'b0;  
      x_scan_file = $fscanf(x_file,"%32b", D_xmem); 
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

    $fclose(x_file);

    // -------------------------------------------------
    // 2) For 2-bit: we have 16 output channels, provided
    //    as two tiles of 8 OCs.
    //    Files:
    //      tile 0: weight_kij0.txt  .. weight_kij8.txt
    //      tile 1: weight_kij9.txt  .. weight_kij17.txt
    // -------------------------------------------------

    for (tile_idx = 0; tile_idx < 2; tile_idx = tile_idx + 1) begin  // two OC tiles

      for (kij=0; kij<9; kij=kij+1) begin  // kij loop (0..8)
        
        // ------------------------------
        // Select weight file
        // ------------------------------
        file_idx = tile_idx*9 + kij;
        case(file_idx)
          0 : w_file_name = {wgt_file, "_kij0.txt"};
          1 : w_file_name = {wgt_file, "_kij1.txt"};
          2 : w_file_name = {wgt_file, "_kij2.txt"};
          3 : w_file_name = {wgt_file, "_kij3.txt"};
          4 : w_file_name = {wgt_file, "_kij4.txt"};
          5 : w_file_name = {wgt_file, "_kij5.txt"};
          6 : w_file_name = {wgt_file, "_kij6.txt"};
          7 : w_file_name = {wgt_file, "_kij7.txt"};
          8 : w_file_name = {wgt_file, "_kij8.txt"};
          9 : w_file_name = {wgt_file, "_kij9.txt"};
          10: w_file_name = {wgt_file, "_kij10.txt"};
          11: w_file_name = {wgt_file, "_kij11.txt"};
          12: w_file_name = {wgt_file, "_kij12.txt"};
          13: w_file_name = {wgt_file, "_kij13.txt"};
          14: w_file_name = {wgt_file, "_kij14.txt"};
          15: w_file_name = {wgt_file, "_kij15.txt"};
          16: w_file_name = {wgt_file, "_kij16.txt"};
          17: w_file_name = {wgt_file, "_kij17.txt"};
        endcase

        w_file = $fopen(w_file_name, "r");
        w_scan_file = $fscanf(w_file,"%s", captured_data);
        w_scan_file = $fscanf(w_file,"%s", captured_data);
        w_scan_file = $fscanf(w_file,"%s", captured_data);

        // small reset between kij’s (same pattern as run_sim)
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

        // ------------------------------------------
        // 2a) Kernel data writing to XMEM (2-bit)
        //     Each line: 64b -> 16×4b weights
        //     We split into:
        //       even indices -> D_xmem_even (32b)
        //       odd  indices -> D_xmem_odd  (32b)
        //     and write them as two consecutive
        //     XMEM words per column.
        // ------------------------------------------
        A_xmem = 11'b10000000000;

        for (t=0; t<col; t=t+1) begin  
          #0.5 clk = 1'b0; 

          // read one 64-bit line from weight file
          w_scan_file = $fscanf(w_file,"%64b", line64);

          D_xmem_even = 32'b0;
          D_xmem_odd  = 32'b0;
          e = 0;
          o = 0;

          // build even/odd 32-bit words (8 nibbles each)
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

          // write EVEN word
          D_xmem   = D_xmem_even;
          WEN_xmem = 0; 
          CEN_xmem = 0;
          #0.5 clk = 1'b1;  // write
          #0.5 clk = 1'b0;  

          // write ODD word (next address)
          A_xmem   = A_xmem + 1;
          D_xmem   = D_xmem_odd;
          WEN_xmem = 0; 
          CEN_xmem = 0;
          #0.5 clk = 1'b1;  // write
          #0.5 clk = 1'b0;  

          // advance to next column base address
          A_xmem = A_xmem + 1;
        end

        #0.5 clk = 1'b0;  
        WEN_xmem = 1;  
        CEN_xmem = 1; 
        A_xmem   = 0;
        #0.5 clk = 1'b1; 

        $fclose(w_file);

        // ------------------------------------------
        // 2b) Kernel data writing to L0
        //     Now we stream EVEN then ODD words
        //     through L0. Since we wrote 2*col
        //     words, we also do 2*col L0 writes.
        // ------------------------------------------
        A_xmem = 11'b10000000000;
        #0.5 clk = 1'b0; 
        WEN_xmem = 1; 
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

        // ------------------------------------------
        // 2c) Kernel loading to PEs
        //     2*col cycles so each MAC_TILE sees:
        //       first weight  -> b_even
        //       second weight -> b_odd
        // ------------------------------------------
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

        // ------------------------------------------
        // 2d) Activation data writing to L0
        //     (same as 4-bit)
        // ------------------------------------------
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

        // ------------------------------------------
        // 2e) Execution (same structure)
        // ------------------------------------------
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

        // ------------------------------------------
        // 2f) OFIFO read -> PMEM (same as 4-bit)
        // ------------------------------------------
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
    end   // tile loop

    // -------------------------------------------------
    // 3) Accumulation + comparison
    //    For now we re-use the same accumulation
    //    block you already have in run_sim.
    //    (If your 2-bit golden output layout is
    //    different, you may need to adjust this
    //    part separately.)
    // -------------------------------------------------

    // Open golden output
    out_file = $fopen(out_file, "r");
    out_scan_file = $fscanf(out_file,"%s", answer); 
    out_scan_file = $fscanf(out_file,"%s", answer); 
    out_scan_file = $fscanf(out_file,"%s", answer); 

    error = 0;
    $display("############ Verification Start (2-bit) #############"); 

    for (i=0; i<len_onij+1; i=i+1) begin 
      #0.5 clk = 1'b0; 
      relu = 0;
      #0.5 clk = 1'b1; 

      if (i>0) begin
        out_scan_file = $fscanf(out_file,"%128b", answer);
        if (sfp_out == answer)
          $display("%2d-th output featuremap Data matched! :D", i); 
        else begin
          $display("%2d-th output featuremap Data ERROR!!", i); 
          $display("sfpout: %128b", sfp_out);
          $display("answer: %128b", answer);
          error = 1;
        end
      end

      // same accumulation loop as your current tb
      #0.5 clk = 1'b0; reset = 1;
      #0.5 clk = 1'b1;  
      #0.5 clk = 1'b0; reset = 0; 
      #0.5 clk = 1'b1;  

      A_pmem     = 0;
      A_pmem_tmp = 0;

      for (j=0; j<len_kij+1; j=j+1) begin 
        #0.5 clk = 1'b0;   
        if (j<len_kij) begin
          CEN_pmem = 0; 
          WEN_pmem = 1; 
          case((j / len_kij_sqrt) % len_kij_sqrt)
            0: A_pmem = (11'd0   + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
            1: A_pmem = (11'd114 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
            2: A_pmem = (11'd228 + i) + 11'd37 * (j % len_kij_sqrt) + 11'd2 * (i / len_onij_sqrt);
          endcase
        end else begin
          CEN_pmem = 1; 
          WEN_pmem = 1;
        end
        if (j>0) acc = 1;  
        #0.5 clk = 1'b1;   
      end

      #0.5 clk = 1'b0; 
      acc  = 0; 
      relu = 1;
      #0.5 clk = 1'b1; 
    end

    relu = 0;

    if (error == 0) begin
      $display("############ No error detected (2-bit) ##############"); 
      $display("########### Project Completed !! ############"); 
    end

    $fclose(out_file);

    for (t=0; t<10; t=t+1) begin  
      #0.5 clk = 1'b0;  
      #0.5 clk = 1'b1;  
    end
  end
endtask