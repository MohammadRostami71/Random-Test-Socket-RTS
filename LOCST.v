module LOCST ();
	parameter PI_Size = 8;
	parameter PO_Size_8 = 8;
    parameter PO_Size_1 = 1;
	parameter SRSG_Size = 16;
	parameter SISR_Size = 16;
	parameter Shift_Cnt = 1; //Scan_Size = 24
	parameter numOfTstCycl = 100;


    integer sigFile, resultFile, cfgFile, faultFile, status;
	integer i, numOfFaults, numOfDetected;
	real coverage;
	
	reg [8*50:1] wireName;
	reg stuckAtVal;
	
	reg clk;
	reg masterRst;
	reg [0:7]inst;

    
    wire [7:0] DOUT_inst, DOUT_address , DOUT_OutData;
	wire [7:0] address;
	wire[7:0] out_data;
	wire So;
    wire Si;
	wire store;
    wire DOUT_store;
	
    wire SOUT_1,SOUT_2,SOUT_3;
	wire NbarT, rstOut;
	wire SRSG_En, SISR_En;
	wire done;
	
	reg[SRSG_Size-1:0] SRSG_Seed;
	reg[SRSG_Size-1:0] SRSG_Poly;
	wire[SRSG_Size-1:0] SRSG_Out;
	
	reg[SISR_Size-1:0] SISR_Seed;
	reg[SISR_Size-1:0] SISR_Poly;
	wire[SISR_Size-1:0] SISR_Out;
	
	reg[SISR_Size-1:0] Golden_SISR_Out;
	
	BS_BSR #(PI_Size) BSC_PI (inst, SRSG_Out[0], NbarT, clk, NbarT, NbarT, ~rstOut, Si, DOUT_inst);
    BS_BSR #(PO_Size_8) BSC_PO_1 (address, So, NbarT, clk, NbarT, NbarT, ~rstOut, SOUT_1, DOUT_address);
    BS_BSR #(PO_Size_8) BSC_PO_2 (out_data, SOUT_1, NbarT, clk, NbarT, NbarT, ~rstOut, SOUT_2, DOUT_OutData);
    BS_BSR #(PO_Size_1) BSC_PO_3 (store, SOUT_2,  NbarT, clk, NbarT, NbarT, ~rstOut, SOUT_3, DOUT_store);
	
	CPU_net CPU (clk, rstOut, DOUT_inst, NbarT, Si, DOUT_address, DOUT_OutData, DOUT_store, So  );
	//(clk, reset, inst, NbarT, Si, address, out_data, store, So);

	SRSG #(SRSG_Size) SRSG_1 (clk, rstOut, SRSG_En, SRSG_Seed, SRSG_Poly, SRSG_Out);
	SISR #(SISR_Size) SISR_1(clk, rstOut, SISR_En, SOUT_3, SISR_Poly, SISR_Seed, SISR_Out);
	OnChipMonitor #(Shift_Cnt, numOfTstCycl) OnChipMonitor_1 (clk, masterRst, NbarT, rstOut, SRSG_En, SISR_En, done);
	
	always #5 clk = !clk;
	
	initial begin
    
    	sigFile = $fopen ("Signature.txt", "w");
		
		SRSG_Seed = 5;
		SISR_Seed = 24;
		
		clk = 0;
		
		//Generate Dictionary of Good Signatures
		//for Various Configurations
		cfgFile = $fopen ("Configuration.txt", "r");
		i = 0;
		while (!$feof(cfgFile)) begin
			i = i + 1;
			//Apply Configurations
			status = $fscanf(cfgFile, "%b %b\n", SRSG_Poly, SISR_Poly);
			masterRst = 1'b1; #1 masterRst = 1'b0;
			//Wait for good signature
			@(posedge done);
			$fwrite( sigFile, "%b\n", SISR_Out);
		end
		$fclose(sigFile);
		$fclose(cfgFile);
		#1;
		// End Dictionary of Good Signatures
		
		// Fault Simulation for every configuration
		cfgFile = $fopen ("Configuration.txt", "r");
		sigFile = $fopen ("Signature.txt", "r");
		i = 0;
		
		while (!$feof(cfgFile)) begin
			i = i + 1;
			//extract golden signature
			status = $fscanf( sigFile, "%b\n", Golden_SISR_Out);
			//Apply Configurations
			status = $fscanf(cfgFile, "%b %b\n", SRSG_Poly, SISR_Poly);
			#1;
			faultFile = $fopen ("faults.flt", "r");
			numOfFaults = 0; numOfDetected = 0;
			
			while(!$feof(faultFile)) begin
				status = $fscanf(faultFile,"%s s@%b\n",wireName, stuckAtVal);
				numOfFaults = numOfFaults + 1;
				$InjectFault(wireName, stuckAtVal);
				masterRst = 1'b1; #1 masterRst = 1'b0;
				@( posedge done ); //Wait for signature
				//compare
				if (SISR_Out != Golden_SISR_Out)
					numOfDetected = numOfDetected + 1;
				$RemoveFault(wireName);
			end // "while(!$feof(faultFile))"
			$fclose(faultFile);
			
			coverage = numOfDetected * 100.0 / numOfFaults;
            			
		end // "while (!$feof(cfgFile)) "
		$fclose(cfgFile);
		$fclose(sigFile);
		$fclose(resultFile);
		$stop;
	end
endmodule
    