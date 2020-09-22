----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : GTX_Avg.vhd
---- Author       : Stefano Basti
---- Description  : Average Calculator or Snapshot for GTX RX Interface
---- Modification History
---- 25/01/2019 First Issue
---- 24/04/2019 Added Snapshot function and Data width parameter
---- 25/04/2019 Added Latency Tester Interface
---- 05/05/2019 Release
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY GTX_Avg IS
GENERIC(
	DataWidth : integer := 8;
	SelFunc : std_logic := '0' --'1' For Average, '0' for Snapshot Function
	);
PORT(
		clk:IN STD_LOGIC;		--system clock
		reset_n:IN STD_LOGIC;
		--To GTX RX Interface
		gtx_clk: in   std_logic;
		gtx_data_in: in  std_logic_vector(DataWidth - 1 downto 0);
		--Stop Average Signal/Snapshot enable
		stop_avg:IN STD_LOGIC;
		--To Latency Tester
		test: in  std_logic;
		recvtest: out   std_logic;
		--Data Out Average/Snapshot
		link_mean:OUT STD_LOGIC_VECTOR (DataWidth - 1 DOWNTO 0)		
		);
		
END ENTITY GTX_Avg;
ARCHITECTURE calc_average Of GTX_Avg IS
signal sreset_n:std_logic;
signal ireset_n:std_logic;
signal sstop:std_logic;
signal istop:std_logic;
signal sum:std_logic_vector(DataWidth + 3 downto 0);
signal avg:std_logic_vector(DataWidth - 1 downto 0);
signal snp:std_logic_vector(DataWidth - 1 downto 0);
signal iavg:std_logic_vector(DataWidth - 1 downto 0);
signal stest:std_logic;
signal itest:std_logic;
BEGIN
--Double stage sync for Metastability
sync_reset:process(gtx_clk, reset_n)
begin
	if reset_n = '0' then
		sreset_n <= '0';
		ireset_n <= '0';
	elsif rising_edge(gtx_clk) then
		ireset_n <= reset_n;
		sreset_n <= ireset_n;
	end if;
end process sync_reset;
--Double stage sync for Metastability
sync_stop:process(gtx_clk, sreset_n)
begin
	if sreset_n = '0' then
		sstop <= '0';
		istop <= '0';
	elsif rising_edge(gtx_clk) then
		istop <= stop_avg;
		sstop <= istop;
	end if;
end process sync_stop;
--Double stage sync for Metastability
sync_test:process(gtx_clk, sreset_n)
begin
	if sreset_n = '0' then
		stest <= '0';
		itest <= '0';
	elsif rising_edge(gtx_clk) then
		itest <= test;
		stest <= itest;
	end if;
end process sync_test;
--Snapshot Process
snap:process(gtx_clk, sreset_n)
variable done:std_logic;
begin
	if sreset_n = '0' then
		snp <= (others=>'0'); 
		done:='0';
	elsif rising_edge(gtx_clk) then
		if(sstop = '0' and done='0') then --Snap enable, oneshot
			snp <= gtx_data_in;
			done:='1';
		else
			done:='0';
		end if;
	end if;
end process snap;
--Latency Tester Packet recognition
check_tstframe:process(gtx_clk, sreset_n)
begin
	if sreset_n = '0' then
		recvtest<='0';
	elsif rising_edge(gtx_clk) then
		if(DataWidth=64) then  --Only for 64bit data frame (High speed link)
			if(stest='1' and (gtx_data_in (15 downto 8)=X"FA" or gtx_data_in (23 downto 16)=X"FA"))then
				recvtest<='1';
			elsif (stest='0') then
				recvtest<='0';
			end if;
		else
			recvtest<='0';
		end if;
	end if;
end process check_tstframe;
--Average Process
average:process(gtx_clk, sreset_n)
variable i:integer;
begin
	if sreset_n = '0' then
		sum <= (others=>'0'); 
		i:=0;
	elsif rising_edge(gtx_clk) then
		if(sstop = '1') then  --Stop Average
			sum<=(others => '0');
			i:=0;
		else
			sum<=sum + gtx_data_in;
			i:= i+1;
			if (i=17) then
				avg<=sum(DataWidth + 3 downto 4); --Average of 16 data sample
				sum <= (others=>'0'); 
				i:=0;
			end if;
		end if;
	end if;
end process average;
--Double stage sync for Metastability
sync_out:process(clk, reset_n)
begin
	if reset_n = '0' then
		link_mean <= (others => '0');
		iavg <= (others => '0');
	elsif rising_edge(clk) then
		if(SelFunc='1')then --Average or Snapshot selector
			iavg <= avg;
		else
			iavg <= snp;
		end if;
		link_mean <= iavg;
	end if;
end process sync_out;

	

END ARCHITECTURE calc_average;