library verilog;
use verilog.vl_types.all;
entity elevator_tb is
    generic(
        FLOOR_MIN       : integer := 1;
        FLOOR_MAX       : integer := 8;
        CLK_PERIOD      : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FLOOR_MIN : constant is 1;
    attribute mti_svvh_generic_type of FLOOR_MAX : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end elevator_tb;
