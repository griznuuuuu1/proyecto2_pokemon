LIBRARY IEEE               ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL   ;
-----------------------------------
LIBRARY PLL_40MHz          ;
USE PLL_40MHz.ALL          ;
USE WORK.basic_package.ALL ;
USE WORK.VGA_package.ALL   ;
-----------------------------------------------------
ENTITY battle_engine IS
	PORT
	(
		CLK           : IN  UINT01;
		RST           : IN  UINT01;
		UP_SIG        : IN  UINT01;
		DOWN_SIG      : IN  UINT01;
	);
END ENTITY battle_engine;
-----------------------------------------------------
ARCHITECTURE functional OF battle_engine IS
BEGIN
	
	
	
END ARCHITECTURE functional;















