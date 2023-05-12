//1.23 format
typedef struct packed {
    logic signed [23:0] I;
    logic signed [23:0] Q;
} Samp;

//3.24 format
typedef struct packed {
    logic signed [26:0] I;
    logic signed [26:0] Q;
} Coef;

//2.23 format		
typedef struct packed{
    logic signed [24:0] I; //real
    logic signed [24:0] Q; //imaginary
} Sum;

//5.47 format
typedef struct packed{
    logic signed [51:0] I;
    logic signed [51:0] Q;
} Partial_product;

//9.29 format
typedef struct packed{
    logic signed [37:0] I;
    logic signed [37:0] Q;
} Full_Product;

typedef enum { 
    idle,
    WaitForData,
    Multiplying
} mult_state_type;

typedef enum {
    Idle,
    PartialProductsAccumulation,
    FinalProductAccumulation
} accum_state_type;

