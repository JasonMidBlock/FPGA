library verilog;
use verilog.vl_types.all;
entity elevator is
    generic(
        FLOOR_MIN       : integer := 1;
        FLOOR_MAX       : integer := 8;
        TIME_MOVE       : integer := 5;
        TIME_DOOR_OPEN  : integer := 5;
        TIME_DOOR_HOLD  : integer := 5;
        TIME_DOOR_CLOSE : integer := 5
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        internal_req    : in     vl_logic_vector;
        external_up_req : in     vl_logic_vector;
        external_down_req: in     vl_logic_vector;
        current_floor   : out    vl_logic_vector(3 downto 0);
        door_state      : out    vl_logic;
        elevator_state  : out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FLOOR_MIN : constant is 1;
    attribute mti_svvh_generic_type of FLOOR_MAX : constant is 1;
    attribute mti_svvh_generic_type of TIME_MOVE : constant is 1;
    attribute mti_svvh_generic_type of TIME_DOOR_OPEN : constant is 1;
    attribute mti_svvh_generic_type of TIME_DOOR_HOLD : constant is 1;
    attribute mti_svvh_generic_type of TIME_DOOR_CLOSE : constant is 1;
end elevator;
