typedef struct packed {
    logic [23:0] I;
    logic [23:0] Q;
} Samp;

typedef struct packed {
    logic [26:0] I;
    logic [26:0] Q;
} Coef;

//1.23 format
typedef struct packed{
    logic [23:0] I; //real
    logic [23:0] Q; //imaginary
} Sum;

//4.47 format
typedef struct packed{
    logic [50:0] I;
    logic [50:0] Q;
} Partial_product;