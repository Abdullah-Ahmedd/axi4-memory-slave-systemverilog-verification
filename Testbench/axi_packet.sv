//declaring an enum (bit used to defined if we are a read or a write)
typedef enum bit
{ write , read } wr_bit;
//Declaring an enum for the W_BRESP states
typedef enum logic [ 2 : 0 ]
{okay , exokay , slverr , decerr } resp;


//declaring the transcation class
class transcation;
//Declaring parameters
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 16;
parameter LEN_WIDTH = 8;
parameter SIZE_WIDTH = 3;
 parameter MEM_DEPTH = 1024;
parameter MEM_ADDR_WIDTH = $clog2( MEM_DEPTH ) ;

///////////////////////////////////////////
//          Signal declarations         //
//////////////////////////////////////////

//and signal commented mean it was not used so i commented it 


  //1- Write address channel 
    rand logic [ ADDR_WIDTH - 1 : 0 ] AWADDR;
    rand logic [ LEN_WIDTH - 1 : 0 ] AWLEN;
    rand logic [ SIZE_WIDTH - 1 : 0 ] AWSIZE;
    //rand logic AWVALID;
   // rand logic AWREADY;



  //2- Write data channel
    rand logic [ DATA_WIDTH - 1 : 0 ] WDATA []; //made it a dynamic array as i want to store all the written data
    //rand logic WLAST;
    //rand logic WVALID;
   //rand logic WREADY;


  // 3-Write responce channel
    //rand logic [ 1 : 0 ] BRESP;
   //rand logic BVALID;
  //rand logic BREADY;



  //4-Read address channel
    rand logic [ ADDR_WIDTH - 1 : 0 ] ARADDR;
    rand logic [ LEN_WIDTH - 1 : 0 ] ARLEN;
    rand logic [ SIZE_WIDTH - 1 : 0 ] ARSIZE;
    //rand logic ARVALID;
    //rand logic ARREADY;    



 //5-Read data channel
  rand logic [ DATA_WIDTH - 1 : 0 ] RDATA [] ;//made it a dynamic array as i want to store all the read data
  rand logic [ 1 : 0 ] RRESP;
  //rand logic RLAST;
  //rand logic RVALID;
  //rand logic RREADY;

//declaring the read, write bit 
rand wr_bit bitt;


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        CONSTRAINTS                                             //
////////////////////////////////////////////////////////////////////////////////////////////////////

constraint size_c_write
{ AWSIZE == 3'b010; } //as this will give 4 bytes which is 32 bit (our design default)

constraint size_c_read
{ ARSIZE == 3'b010; } //as this will give 4 bytes which is 32 bit (our design default)

constraint length_write
{ AWLEN dist  { [0:15]:=70 , [16:63]:=20, [64:255]:=10 }; } //did a constraint on the length of the burst 

constraint length_read
{ ARLEN dist  { [0:15]:=70 , [16:63]:=20, [64:255]:=10 }; } //did a constraint on the length of the burst 


//Constraint to make sure the boundaries are legal and followed 
constraint boundary_4KB
{
if( bitt ) //bitt==1 mean read
  ( ARADDR[ 11 : 0 ] + ( ARLEN + 1 ) * ( 1<< ARSIZE ) ) <= 4096;
else       //bitt==0 mean write
  ( AWADDR[ 11 : 0 ] + ( AWLEN + 1 ) * ( 1<< AWSIZE ) ) <= 4096;
  
}
//exaclty as the check_4KB function concept 
//1) [ 11 : 0 ] as the 4096 need 12 bits 
// (len + 1 ) as the number of beats per burst is len+1
// (1<<size) as the size of the beat is 2^size
//so ARADDR[ 11 : 0 ] give the first offset in the page
//and we add on it the total transfered bytes in the burst 
//to get the final offset and make sure it is below the 4KB page size


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        FUNCTIONS                                               //
////////////////////////////////////////////////////////////////////////////////////////////////////


//1-post randomization
function void post_randomize();
  if( !bitt ) //write
    begin
      WDATA = new[ AWLEN + 1 ] ;
      foreach(WDATA[ i ] )
      WDATA = $urandom(); 
    end
  else //read
      WDATA.delete();
      RDATA=new[ ARLEN + 1 ];
endfunction 

//2- copying the components of the class to another class
function transcation copy();
  transcation cop = new();
  cop.AWADDR = this.AWADDR;
  cop.AWLEN = this.AWLEN;
  cop.AWSIZE = this.AWSIZE;
  cop.RRESP =this.RRESP;


  cop.WDATA = new[ this.WDATA.size( ) ];
  cop.RDATA = new[ this.RDATA.size( ) ];
  foreach(this.WDATA[i]) cop.WDATA[ i ] = this.WDATA[ i ] ;
  foreach(this.RDATA[i]) cop.RDATA[ i ] = this.RDATA[ i ] ;

  return cop;
endfunction


//3-display function 
function void display();
  $display("----------------------------------------------------------------------------------------");
  $display("len=%0d;size=%0d;beats=%0d;addresss=%0h;operation=%0s;", AWLEN , AWSIZE , AWLEN+1 , AWADDR ,bitt );
  if( bitt ) //read
    begin
      foreach( WDATA[i] )
       $display("WDATA[%0d] = %0d", i , WDATA[ i ] );
    end
  else
    begin
      foreach( RDATA[i] )
       $display("RDATA[%0d] = %0d", i , RDATA[ i ] );      
    end
  $display("----------------------------------------------------------------------------------------");

endfunction


endclass 