----------------------------------------------------------------
---- INFN Sezione di Roma Tre
---- Project Name : RMU
---- File         : RMU_Packer.vhd
---- Author       : Stefano Basti
---- Description  : RMU Packet Generator 
---- Modification History
---- 17/02/2019 First Issue
---- 05/05/2019 Release
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY RMU_Packer IS
PORT(
		reset_n:IN STD_LOGIC;
		--GTX TX Clk (High speed link)
		gtx_clk: in std_logic;
		--TTIM0 GTX RX Interface Signal
		TTIM0_clk: in std_logic;
		TTIM0_data: in  std_logic_vector(15 downto 0);
		TTIM0_charisk: in  std_logic_vector(1 downto 0);
		TTIM0_allign: in  std_logic;
		--TTIM1 GTX RX Interface Signal
		TTIM1_clk: in std_logic;
		TTIM1_data: in  std_logic_vector(15 downto 0);
		TTIM1_charisk: in  std_logic_vector(1 downto 0);
		TTIM1_allign: in  std_logic;
		--TTIM2 GTX RX Interface Signal
		TTIM2_clk: in std_logic;
		TTIM2_data: in  std_logic_vector(15 downto 0);
		TTIM2_charisk: in  std_logic_vector(1 downto 0);
		TTIM2_allign: in  std_logic;
		--TTIM3 GTX RX Interface Signal
		TTIM3_clk: in std_logic;
		TTIM3_data: in  std_logic_vector(15 downto 0);
		TTIM3_charisk: in  std_logic_vector(1 downto 0);
		TTIM3_allign: in  std_logic;
		--TTIM4 GTX RX Interface Signal
		TTIM4_clk: in std_logic;
		TTIM4_data: in  std_logic_vector(15 downto 0);
		TTIM4_charisk: in  std_logic_vector(1 downto 0);
		TTIM4_allign: in  std_logic;
		--TTIM5 GTX RX Interface Signal
		TTIM5_clk: in std_logic;
		TTIM5_data: in  std_logic_vector(15 downto 0);
		TTIM5_charisk: in  std_logic_vector(1 downto 0);
		TTIM5_allign: in  std_logic;
		--TTIM6 GTX RX Interface Signal
		TTIM6_clk: in std_logic;
		TTIM6_data: in  std_logic_vector(15 downto 0);
		TTIM6_charisk: in  std_logic_vector(1 downto 0);
		TTIM6_allign: in  std_logic;
		--Comma Insertion Counter Value	
		count:in std_logic_vector(15 downto 0);
		--GTX TX High Speed Data Interface Signal
		charisk: out  std_logic_vector(7 downto 0);
		data_out:out std_logic_vector(63 downto 0);
        data_in : in std_logic_vector(63 downto 0);
        CTU_align : in std_logic;
        --TTIM TX data generate
        TTIM_txclk : in std_logic;
        TTIM0_txdata : out std_logic_vector(15 downto 0);
        TTIM1_txdata : out std_logic_vector(15 downto 0);
        TTIM2_txdata : out std_logic_vector(15 downto 0);
        TTIM3_txdata : out std_logic_vector(15 downto 0);
        TTIM4_txdata : out std_logic_vector(15 downto 0);
        TTIM5_txdata : out std_logic_vector(15 downto 0);
        TTIM6_txdata : out std_logic_vector(15 downto 0)
		);
		
END ENTITY RMU_Packer;
ARCHITECTURE data_packer Of RMU_Packer IS

signal TTIM0_data_in:std_logic_vector(7 downto 0);
signal TTIM1_data_in:std_logic_vector(7 downto 0);
signal TTIM2_data_in:std_logic_vector(7 downto 0);
signal TTIM3_data_in:std_logic_vector(7 downto 0);
signal TTIM4_data_in:std_logic_vector(7 downto 0);
signal TTIM5_data_in:std_logic_vector(7 downto 0);
signal TTIM6_data_in:std_logic_vector(7 downto 0);
signal CTU_data_i : std_logic_vector(63 downto 0);
signal scount:std_logic_vector(15 downto 0);
signal icount:std_logic_vector(15 downto 0);
signal stest:std_logic;
signal itest:std_logic;

signal sreset_n:std_logic;
signal ireset_n:std_logic;


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
sync_count:process(gtx_clk, sreset_n)
begin
	if sreset_n = '0' then
		scount <= (others => '0');
		icount <= (others => '0');
	elsif rising_edge(gtx_clk) then
		icount <= count;
		scount <= icount;
	end if;
end process sync_count;
--Data Extractor from TTIM0 Packet
alling_0:process(TTIM0_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM0_data_in <= (others => '0');
	elsif rising_edge(TTIM0_clk) then
		--if(TTIM0_charisk = "00" and TTIM0_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM0_data_in <= TTIM0_data(7 downto 0);       --Extract only data field
		if(TTIM0_allign= '1' and TTIM0_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM0_data_in <= TTIM0_data(15 downto 8);
		else
			TTIM0_data_in <= (others => '0');
		end if;
	end if;
end process alling_0;
--Data Extractor from TTIM1 Packet
alling_1:process(TTIM1_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM1_data_in <= (others => '0');
	elsif rising_edge(TTIM1_clk) then
		--if(TTIM1_charisk = "00" and TTIM1_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM1_data_in <= TTIM1_data(7 downto 0);       --Extract only data field
		if(TTIM1_allign= '1' and TTIM1_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM1_data_in <= TTIM1_data(15 downto 8);
		else
			TTIM1_data_in <= (others => '0');
		end if;
	end if;
end process alling_1;
--Data Extractor from TTIM2 Packet
alling_2:process(TTIM2_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM2_data_in <= (others => '0');
	elsif rising_edge(TTIM2_clk) then
		--if(TTIM2_charisk = "00" and TTIM2_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM2_data_in <= TTIM2_data(7 downto 0);       --Extract only data field
		if(TTIM2_allign= '1' and TTIM2_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM2_data_in <= TTIM2_data(15 downto 8);
		else
			TTIM2_data_in <= (others => '0');
		end if;
	end if;
end process alling_2;
--Data Extractor from TTIM3 Packet
alling_3:process(TTIM3_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM3_data_in <= (others => '0');
	elsif rising_edge(TTIM3_clk) then
		--if(TTIM3_charisk = "00" and TTIM3_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM3_data_in <= TTIM3_data(7 downto 0);       --Extract only data field
		if(TTIM3_allign= '1' and TTIM3_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM3_data_in <= TTIM3_data(15 downto 8);
		else
			TTIM3_data_in <= (others => '0');
		end if;
	end if;
end process alling_3;
--Data Extractor from TTIM4 Packet
alling_4:process(TTIM4_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM4_data_in <= (others => '0');
	elsif rising_edge(TTIM4_clk) then
		--if(TTIM4_charisk = "00" and TTIM4_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM4_data_in <= TTIM4_data(7 downto 0);       --Extract only data field
		if(TTIM4_allign= '1' and TTIM4_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM4_data_in <= TTIM4_data(15 downto 8);
		else
			TTIM4_data_in <= (others => '0');
		end if;
	end if;
end process alling_4;
--Data Extractor from TTIM5 Packet
alling_5:process(TTIM5_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM5_data_in <= (others => '0');
	elsif rising_edge(TTIM5_clk) then
		--if(TTIM5_charisk = "00" and TTIM5_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM5_data_in <= TTIM5_data(7 downto 0);       --Extract only data field
		if(TTIM5_allign= '1' and TTIM5_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM5_data_in <= TTIM5_data(15 downto 8);
		else
			TTIM5_data_in <= (others => '0');
		end if;
	end if;
end process alling_5;
--Data Extractor from TTIM6 Packet
alling_6:process(TTIM6_clk, reset_n)
begin
	if reset_n = '0' then
		TTIM6_data_in <= (others => '0');
	elsif rising_edge(TTIM6_clk) then
		--if(TTIM6_charisk = "00" and TTIM6_allign= '1')then --Wait Link Alligned and no comma inserted
		--	TTIM6_data_in <= TTIM6_data(7 downto 0);       --Extract only data field
		if(TTIM6_allign= '1' and TTIM6_data(7 downto 0) = x"BC")then                       --if comma received retain previous data
			TTIM6_data_in <= TTIM6_data(15 downto 8);
		else
			TTIM6_data_in <= (others => '0');
		end if;
	end if;
end process alling_6;
--RMU Packet Former and Comma insertion logic
data_proc:process(gtx_clk, sreset_n)
variable i: integer:=0;
begin
	if sreset_n = '0' then
		data_out <= (others => '0');
		charisk<=X"00";
		i:=1;
	elsif rising_edge(gtx_clk) then
		data_out<= TTIM6_data_in & TTIM5_data_in & TTIM4_data_in & TTIM3_data_in & TTIM2_data_in & TTIM1_data_in & TTIM0_data_in & X"bc" ; --Standard RMU packet
		if(i=scount) then --When Counter reached count value enable charisk for encode first byte as comma (if comma always enable receiver doesn't allign properly)
			charisk<=X"01";
			i:=1;
		else
			charisk<=X"00";
			if(scount > X"00") then
				i:= i + 1;
			end if;
		end if;
	end if;
end process data_proc;
--RMU data de-pack
process(TTIM_txclk)
begin
    if sreset_n = '0' or CTU_align = '0' then
        TTIM0_txdata <= x"00BC";
        TTIM1_txdata <= x"00BC";
        TTIM2_txdata <= x"00BC";
        TTIM3_txdata <= x"00BC";
        TTIM4_txdata <= x"00BC";
        TTIM5_txdata <= x"00BC";
        TTIM6_txdata <= x"00BC";
        CTU_data_i <= (others => '0');
    elsif rising_edge(TTIM_txclk) then
        CTU_data_i <= data_in;
        TTIM0_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM1_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM2_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM3_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM4_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM5_txdata <= CTU_data_i(63 downto 56) & x"BC";
        TTIM6_txdata <= CTU_data_i(63 downto 56) & x"BC";
        -- TTIM1_txdata <= CTU_data_i(23 downto 16) & x"BC";
        -- TTIM2_txdata <= CTU_data_i(31 downto 24) & x"BC";
        -- TTIM3_txdata <= CTU_data_i(39 downto 32) & x"BC";
        -- TTIM4_txdata <= CTU_data_i(47 downto 40) & x"BC";
        -- TTIM5_txdata <= CTU_data_i(55 downto 48) & x"BC";
        -- TTIM6_txdata <= CTU_data_i(63 downto 56) & x"BC";
    end if;
end process;

END ARCHITECTURE data_packer;