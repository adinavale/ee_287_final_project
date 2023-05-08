typedef struct packed {
    logic signed [23:0] I;
    logic signed [23:0] Q;
} Samp;

typedef struct packed {
    logic signed [26:0] I;
    logic signed [26:0] Q;
} Coef;

//1.23 format
typedef struct packed{
    logic signed [23:0] I; //real
    logic signed [23:0] Q; //imaginary
} Sum;

//4.47 format
typedef struct packed{
    logic signed [50:0] I;
    logic signed [50:0] Q;
} Partial_product;