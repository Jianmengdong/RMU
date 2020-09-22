----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : Latency_Counter.vhd
---- Author       : Stefano Basti
---- Description  : Latency Counter
---- Modification History
---- 25/04/2019 First Issue
---- 05/05/2019 Release
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY Latency_Counter IS
PORT(
		reset_n:in STD_LOGIC;
		clk: in   std_logic;
		--TX interface Clock (TTIM Emulator)
		txclk: in   std_logic;
		--Test Signal
		sendtest: in   std_logic;
		recvtest: in   std_logic;
		test: in   std_logic;
		--Latency Value
		count:out std_logic_vector(7 downto 0)
		);
		
END ENTITY Latency_Counter;
ARCHITECTURE counter Of Latency_Counter IS

signal sreset_n:std_logic;
signal ireset_n:std_logic;

signal iicount:std_logic_vector(7 downto 0);
signal icount:integer range 0 to 255;

signal stest:std_logic;
signal itest:std_logic;

BEGIN
--Double stage sync for Metastability
sync_reset:process(txclk, reset_n)
begin
	if reset_n = '0' then
		sreset_n <= '0';
		ireset_n <= '0';
	elsif rising_edge(txclk) then
		ireset_n <= reset_n;
		sreset_n <= ireset_n;
	end if;
end process sync_reset;
--Double stage sync for Metastability
sync_count:process(clk, reset_n)
begin
	if reset_n = '0' then
		iicount <= (others => '0');
		count <= (others => '0');
	elsif rising_edge(clk) then
		iicount <= CONV_STD_LOGIC_VECTOR(icount,8);
		count <= iicount;
	end if;
end process sync_count;
--Double stage sync for Metastability
sync_test:process(txclk, sreset_n)
begin
	if sreset_n = '0' then
		stest <= '0';
		itest <= '0';
	elsif rising_edge(txclk) then
		itest <= test;
		stest <= itest;
	end if;
end process sync_test;
--Latency Counter Process
counter:process(txclk, reset_n)
begin
	if sreset_n = '0' then
		icount <= 0;
	elsif rising_edge(txclk) then
		if(stest='1' and sendtest='1' and recvtest='0')then --Counter Start
			icount<= icount + 1;
		elsif(stest = '0') then --Counter Clear
			icount <= 0;
		end if;
	end if;
end process counter;

END ARCHITECTURE counter;