LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.clock_divider_pkg.all;

entity clock_divider_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of clock_divider_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 250;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal rising_edge_is_detected : boolean := false;
    signal falling_edge_detected : boolean := false;

    signal clock_divider : clock_divider_record := init_clock_divider(7);
    signal divided_clock : std_logic;

    constant test_data : std_logic_vector(15 downto 0) := x"acdc";
    signal shift_register : std_logic_vector(15 downto 0) := (others => '0');
    signal spi_data : std_logic := '0';

    signal spi_data_counter : integer range 0 to 15 := 0;

    signal data_was_received : boolean := false;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(data_was_received, "data was not received correctly");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;


            create_clock_divider(clock_divider);
            divided_clock <= get_divided_clock(clock_divider);

            rising_edge_is_detected <= data_delivered_on_rising_edge(clock_divider);
            falling_edge_detected   <= data_delivered_on_falling_edge(clock_divider);

            if data_delivered_on_rising_edge(clock_divider) then
                shift_register <= shift_register(14 downto 0) & spi_data;
            end if;

            if clock_divider_is_ready(clock_divider) then
                check(shift_register = test_data, "did not receive data correctly, got " & to_string(shift_register));
                data_was_received <= true;
            end if;

            if simulation_counter = 15 then 
                request_clock_divider(clock_divider, 16);
            end if;

        end if; -- rising_edge
    end process stimulus;	

    test_spi : process(divided_clock)
    begin
        if rising_edge(divided_clock) then
            spi_data_counter <= (spi_data_counter + 1) mod 16;
            spi_data <= test_data(15 - spi_data_counter);
        end if; --rising_edge
    end process test_spi;	
------------------------------------------------------------------------
end vunit_simulation;
