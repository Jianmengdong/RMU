----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : TTIM_Emulator.vhd
---- Author       : Stefano Basti
---- Description  : TTIM Data Emulator for Testing
---- Modification History
---- 17/02/2019 First Issue
---- 25/04/2019 Added Latency Tester Interface
---- 05/05/2019 Release
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY TTIM_Emulator IS
PORT(
		reset_n:IN STD_LOGIC;
		--To GTX TX Interface
		txusrclk2: in   std_logic;
		txdata: out  std_logic_vector(15 downto 0);
		txcharisk: out  std_logic_vector(1 downto 0);
		--To Latency Tester
		test: in  std_logic;
		sendtest: out   std_logic;
		--Comma Insertion Counter Value	
		count:in std_logic_vector(15 downto 0);
		--Data to send	
		data:in std_logic_vector(7 downto 0)
		);
		
END ENTITY TTIM_Emulator;
ARCHITECTURE data_generator Of TTIM_Emulator IS
signal sdata:std_logic_vector(7 downto 0);
signal idata:std_logic_vector(7 downto 0);
signal scount:std_logic_vector(15 downto 0);
signal icount:std_logic_vector(15 downto 0);
signal sreset_n:std_logic;
signal ireset_n:std_logic;
signal stest:std_logic;
signal itest:std_logic;
signal isendtest:std_logic;

BEGIN
--Double stage sync for Metastability
sync_reset:process(txusrclk2, reset_n)
begin
	if reset_n = '0' then
		sreset_n <= '0';
		ireset_n <= '0';
	elsif rising_edge(txusrclk2) then
		ireset_n <= reset_n;
		sreset_n <= ireset_n;
	end if;
end process sync_reset;
--Double stage sync for Metastability
sync_command:process(txusrclk2, sreset_n)
begin
	if sreset_n = '0' then
		sdata <= (others => '0');
		idata <= (others => '0');
	elsif rising_edge(txusrclk2) then
		idata <= data;
		sdata <= idata;
	end if;
end process sync_command;
--Double stage sync for Metastability
sync_count:process(txusrclk2, sreset_n)
begin
	if sreset_n = '0' then
		scount <= (others => '0');
		icount <= (others => '0');
	elsif rising_edge(txusrclk2) then
		icount <= count;
		scount <= icount;
	end if;
end process sync_count;
--Double stage sync for Metastability
sync_test:process(txusrclk2, sreset_n)
begin
	if sreset_n = '0' then
		stest <= '0';
		itest <= '0';
	elsif rising_edge(txusrclk2) then
		itest <= test;
		stest <= itest;
	end if;
end process sync_test;
--Data Generation with comma insertion logic
data_gen:process(txusrclk2, sreset_n)
variable i: integer:=0;
begin
	if sreset_n = '0' then
		txdata <= (others => '0');
		txcharisk <= (others => '0');
		i:=1;
		isendtest<='0';
	elsif rising_edge(txusrclk2) then
		if(i=scount) then --Insertion of comma after count value reached
			i:=1;
			txdata <= x"00bc";
			txcharisk <= "01";
		else
			if (stest='1' and isendtest='0') then --Test packet
				txdata <= X"80FA";
				isendtest<='1';
			else
				txdata <= X"80" & data; --Standard packet
			end if;
			if stest='0' then --send test clear
				isendtest<='0';
			end if;
			txcharisk <= (others => '0');
			if(scount > X"00") then -- Insertion Comma counter
				i:= i + 1;
			end if;
		end if;
	end if;
end process data_gen;

sendtest<=isendtest;


END ARCHITECTURE data_generator;