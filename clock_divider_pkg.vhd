library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package clock_divider_pkg is

    type clock_divider_record is record
        divided_clock         : std_logic;
        clock_divider_counter : natural;
        clock_divider_max     : natural;
        clock_counter         : natural;
    end record;

------------------------------------------------------------------------
    function init_clock_divider ( divide_clock_by : natural range 2 to 1024)
        return clock_divider_record;

    function init_clock_divider return clock_divider_record;
------------------------------------------------------------------------
    procedure create_clock_divider (
        signal self : inout clock_divider_record);
------------------------------------------------------------------------
    procedure request_clock_divider (
        signal self : inout clock_divider_record;
        number_of_clocks_is : integer);

    procedure request_clock_divider (
        signal self : inout clock_divider_record;
        number_of_clocks_is         : in integer;
        divide_clock_by             : in integer range 2 to 1024);
------------------------------------------------------------------------
    function get_divided_clock ( self : clock_divider_record)
        return std_logic;
------------------------------------------------------------------------
    function data_delivered_on_rising_edge ( self : clock_divider_record)
        return boolean;
------------------------------------------------------------------------
    function data_delivered_on_falling_edge ( self : clock_divider_record)
        return boolean;
------------------------------------------------------------------------
    procedure set_clock_divider (
        signal self : out clock_divider_record;
        clock_divider : in integer range 2 to 1024);
------------------------------------------------------------------------
    function clock_divider_is_ready ( self : clock_divider_record)
        return boolean;
------------------------------------------------------------------------
end package clock_divider_pkg;


package body clock_divider_pkg is

    constant initial_value_clock_divider : clock_divider_record := ('0', 0, 5, 0);

------------------------------------------------------------------------
    function init_clock_divider
    (
        divide_clock_by : natural range 2 to 1024
    )
    return clock_divider_record
    is
        variable returned_value : clock_divider_record;
    begin
        returned_value := initial_value_clock_divider;
        returned_value.clock_divider_max := divide_clock_by;

        return returned_value;
        
    end init_clock_divider;
------------------------------
    function init_clock_divider return clock_divider_record
    is
        variable returned_value : clock_divider_record;
    begin
        returned_value := initial_value_clock_divider;

        return returned_value;
        
    end init_clock_divider;
------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure create_clock_divider
    (
        signal self : inout clock_divider_record
    ) is
    begin
        if self.clock_divider_counter > 0 then
            self.clock_divider_counter <= self.clock_divider_counter - 1;
        end if;

        if self.clock_counter > 0 then
            if self.clock_divider_counter = 0 then
                self.clock_divider_counter <= self.clock_divider_max;
            end if;
        end if;

        if data_delivered_on_rising_edge(self) then
            if self.clock_counter > 0 then
                self.clock_counter <= self.clock_counter - 1;
            end if;
        end if;

        if self.clock_divider_counter > self.clock_divider_max/2 then
            self.divided_clock <= '1';
        else
            self.divided_clock <= '0';
        end if;

    end create_clock_divider;
------------------------------------------------------------------------
    procedure request_clock_divider
    (
        signal self : inout clock_divider_record;
        number_of_clocks_is : integer
    ) is
    begin
        self.clock_counter <= number_of_clocks_is;
        self.clock_divider_counter <= self.clock_divider_max;
        self.divided_clock <= '0';

        
    end request_clock_divider;
------------------------------
    procedure request_clock_divider
    (
        signal self : inout clock_divider_record;
        number_of_clocks_is         : in integer;
        divide_clock_by             : in integer range 2 to 1024
    ) is
    begin
        request_clock_divider(self, number_of_clocks_is);
        self.clock_divider_max <= divide_clock_by-1;
        self.clock_divider_counter <= divide_clock_by-2;

        
    end request_clock_divider;
------------------------------------------------------------------------
------------------------------------------------------------------------
    function get_divided_clock
    (
        self : clock_divider_record
    )
    return std_logic 
    is
    begin
        return self.divided_clock;
    end get_divided_clock;
------------------------------------------------------------------------
    function data_delivered_on_rising_edge
    (
        self : clock_divider_record
    )
    return boolean
    is
        variable purkka : integer := 0;
    begin
        if self.clock_divider_max > 1 then
            purkka := -1;
        else
            purkka := 1;
        end if;
        return self.clock_divider_counter = self.clock_divider_max/2 + purkka;
    end data_delivered_on_rising_edge;
------------------------------------------------------------------------
    function data_delivered_on_falling_edge
    (
        self : clock_divider_record
    )
    return boolean
    is
    begin
        return self.clock_divider_counter = self.clock_divider_max - 1;
    end data_delivered_on_falling_edge;
------------------------------------------------------------------------
    procedure set_clock_divider
    (
        signal self : out clock_divider_record;
        clock_divider : in integer range 2 to 1024
    ) is
    begin
        self.clock_divider_max <= clock_divider;
    end set_clock_divider;
------------------------------------------------------------------------
    function clock_divider_is_ready
    (
        self : clock_divider_record
    )
    return boolean is
    begin
        
        return self.clock_counter = 0 and data_delivered_on_rising_edge(self);
    end clock_divider_is_ready;
------------------------------------------------------------------------
end package body clock_divider_pkg;
