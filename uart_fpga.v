
//UART_TX PIN_D9 FPGA UART Receiver 3.3V
//UART_RX PIN_E9 FPGA UART Transmitter 3.3V
//af14 clk 
//HEX0[0] PIN_AE26 Seven Segment Digit 0[0] 3.3V
//HEX0[1] PIN_AE27 Seven Segment Digit 0[1] 3.3V
//HEX0[2] PIN_AE28 Seven Segment Digit 0[2] 3.3V
//HEX0[3] PIN_AG27 Seven Segment Digit 0[3] 3.3V
//HEX0[4] PIN_AF28 Seven Segment Digit 0[4] 3.3V


//HEX0[5] PIN_AG28 Seven Segment Digit 0[5] 3.3V
//HEX0[6] PIN_AH28 Seven Segment Digit 0[6] 3.3V

module uart_fpga(
                      
    input wire clk , receiver , start , 
	        
    output transmiter,led0 , led1 , led2 , led3 ,led4 ,led5 , led6
    
	 
);

    reg address ; 
	
    wire [199:0] data ;
	 wire [199:0] data_in ; 
    wire  wren ; 
	 wire [199:0] matriz_saida_da_memoria  ;  
	 
    ram ram_inst (  
	 
        .address(  address  ),  
        .clock(  clk  ),  
        .data(  data  ), 
        .wren(  wren  ),  
        .q(  matriz_saida_da_memoria  )
		  
    );
    
   
	
   uart_receiver(

    .clk(clk),
	 
    .receiver(receiver),

	 
    .data_for_memory_(  data_in ) ,
    .write_in_memory( wren ) 
);

    wire busy_uart ;
    
uart_transmitter (
    .clk(clk),
    .transmit( start ),
    .data( return_for_c_cody ),
    .tx( transmiter ) , 
    .busy(busy_uart) 
);




   initial begin 
	     address <= 0 ; 
	    
	
	end 
	


         
   assign data = data_in ; 			
	
		
	
	assign led0 = data_in[0] ; 
	assign led1  = data_in[1] ; 
	assign led2 = data_in[2]  ; 
	assign led3 = data_in[3] ;
	assign led4 = data_in[4];
	assign led5 = data_in[5];
	assign led6 = data_in[6];
	
   
	reg [ 25:0 ] counter ; 
	reg clk_1segundo ; 
	
	always @(posedge clk ) begin
	
	     if (counter < 50_000_000 - 1) begin 
		  
		      counter <= counter + 1 ; 
		  
		  end  else begin 
		  
		         counter <= 0 ; 
					clk_1segundo <=  ~clk_1segundo ; 
					
		  end 
		  
		   
	
	end 

   
   wire [7:0] return_for_c_cody ; 
  
	reg start_uart ; 
	
	assign return_for_c_cody  =  8'b00000111 ; 
	
	always @(posedge clk_1segundo) begin
	
        if (!busy_uart) begin
		  
            start_uart <= 1;
        end else begin
            start_uart <= 0;
        end
    end
	
	
	
	
endmodule
