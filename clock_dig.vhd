library ieee;
use ieee.std_logic_1164.all;
entity clock_dig is
port( clk_50Mhz : in std_logic;
 reset,ajuste : in std_logic;
 ajuste_hh,ajuste_mm : in std_logic;
 hex0,hex1,hex2,hex3,hex4,hex5 :out std_logic_vector(0 to 6));
end entity;
architecture rtl of clock_dig is 
signal clk0,clk1,clk2,clk3,clk4,clk5 : std_logic := '0';
signal clk_a1,clk_a2 :  std_logic := '0';
signal ajuste_sync : std_logic;
constant max : integer := 50000000;
constant half : integer := max/2;
signal count : integer range 0 to max;
function   numero (digito : integer) return std_logic_vector is 
variable hex : std_logic_vector(0 to 6);
begin
 case digito is
  when 0 => hex := "0000001";
  when 1 => hex := "1001111";
  when 2 => hex := "0010010";
  when 3 => hex := "0000110";
  when 4 => hex := "1001100";
  when 5 => hex := "0100100";
  when 6 => hex := "1100000";
  when 7 => hex := "0001111";
  when 8 => hex := "0000000";
  when 9 => hex := "0000100";
  when others => null;
 end case;
 return(hex);
end numero;
begin
--definimos el clock de 1 hz
process(clk_50Mhz) 
begin
 if (clk_50Mhz' event and clk_50Mhz= '1') then
  if (count < max)then 
   count<= count + 1;
  else count <= 1;
  end if;
  if (count <= half) then clk0 <='0';
  else clk0 <= '1';
  end if;
 end if;
end process;

--definimos el reloj como tal 
process(clk0,reset,ajuste,ajuste_hh,ajuste_mm)
 variable uu_s : integer range 0 to 10;
 variable dd_s : integer range 0 to 6;
 variable uu_m : integer range 0 to 10;
 variable dd_m : integer range 0 to 6;
 variable uu_h : integer range 0 to 10;
 variable dd_h : integer range 0 to 3;
begin
--señal asincrona de reset
if(reset= '0') then 
uu_s := 0;
dd_s := 0;
uu_m := 0;
dd_m := 0;
uu_h := 0;
dd_h := 0;
else
--definimos segundos contador mod 60
if (clk0' event and clk0='1') then
 uu_s := uu_s + 1;
 clk1 <= '0';
 if (uu_s=10) then
  uu_s := 0;
  clk1 <= '1';
 end if;
end if;
if (clk1' event and clk1='1') then
 dd_s := dd_s + 1;
 clk2 <= '0';
 if (dd_s=6) then
  dd_s := 0;
  clk2 <= '1';
 end if;
end if;

--señal de ajuste minutos

--sincronizamos a los segundos
if (clk0' event and clk0='0') then 
 ajuste_sync <= ajuste;
end if;
clk_a1 <= (clk2 and not ajuste_sync) or (ajuste_mm and ajuste_sync);

--definimos minutos contador mod 60
if (clk_a1' event and clk_a1= '1') then  
 uu_m:= uu_m + 1;
 clk3 <= '0';
 if (uu_m=10) then 
  uu_m := 0;
  clk3 <= '1';
 end if;
end if;
if (clk3' event and clk3= '1') then 
 dd_m:= dd_m + 1;
 clk4 <= '0';
 if (dd_m=6) then
  dd_m:= 0;
  clk4 <= '1';
 end if;
end if;

--señal de ajuste minutos
clk_a2<= (clk4 and not ajuste_sync) or (ajuste_hh and ajuste_sync);

--definimos horas contador mod 24 
if (clk_a2' event and clk_a2= '1') then 
 uu_h:= uu_h + 1;
 clk5 <= '0';
 if (uu_h=10)then
  uu_h:= 0;
  clk5 <= '1';
 end if;
end if;
if (clk5' event and clk5= '1') then 
 dd_h:= dd_h + 1;
end if;
if (dd_h= 2 and uu_h= 4) then
uu_h:= 0;
dd_h:= 0;
end if;
end if;
--mostramos en displays
hex0 <= numero(uu_s);
hex1 <= numero(dd_s);
hex2 <= numero(uu_m);
hex3 <= numero(dd_m);
hex4 <= numero(uu_h);
hex5 <= numero(dd_h);
end process;
end architecture;