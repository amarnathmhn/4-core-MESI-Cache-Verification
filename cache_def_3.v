//Constant values defintion as per prob statement - Number of bits basis
`define SET_SIZE 		14
`define ASSOCIATIVITY 		2 
`define NUM_BYTES 		2
`define BYTE_SIZE 		3
`define ADDRESSSIZE 		32
`define MESI_SIZE 		2

// Cache line segregation calculation of Index / Valid / MESI / Tag / Data / Blk_offset sizes
`define BLK_OFFSET_SIZE 	(`NUM_BYTES)
`define INDEX_SIZE 		(`SET_SIZE)
`define TAG_SIZE 		((`ADDRESSSIZE) - (`BLK_OFFSET_SIZE) - (`INDEX_SIZE))
`define DATA_SIZE 		(1<<((`BLK_OFFSET_SIZE) + (`BYTE_SIZE)))

// calculation for LRU structure
`define NUM_OF_SETS 		(1<<(`SET_SIZE))
`define LRU_SIZE 		((1<<`ASSOCIATIVITY)-1)

// cache structure parameter calculation
`define CACHE_DATA_SIZE		(`DATA_SIZE)
`define CACHE_TAG_MESI_SIZE 	((`TAG_SIZE) + (`MESI_SIZE))
`define CACHE_DEPTH 		(1<<((`INDEX_SIZE)+(`ASSOCIATIVITY)))

// each Address input segregation - bit_wise
`define BLK_OFFSET_LSB 		0
`define BLK_OFFSET_MSB 		(`BLK_OFFSET_SIZE-1)
`define INDEX_LSB 		(`BLK_OFFSET_SIZE)
`define INDEX_MSB 		((`BLK_OFFSET_SIZE) + (`INDEX_SIZE) - 1)
`define TAG_LSB 		((`BLK_OFFSET_SIZE) + (`INDEX_SIZE))
`define TAG_MSB 		31

// each cache line segregation - bit_wise
`define CACHE_TAG_MSB 		((`MESI_SIZE) + (`TAG_SIZE) - 1)
`define CACHE_TAG_LSB 		(`MESI_SIZE)
`define CACHE_MESI_MSB 		((`MESI_SIZE) - 1)
`define CACHE_MESI_LSB 		0
`define CACHE_DATA_MSB 		((`DATA_SIZE) - 1)
`define CACHE_DATA_LSB 		0

