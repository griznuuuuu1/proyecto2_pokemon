LIBRARY IEEE               ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL   ;
-----------------------------------
LIBRARY PLL_40MHz          ;
USE PLL_40MHz.ALL          ;
USE WORK.basic_package.ALL ;
USE WORK.VGA_package.ALL   ;
-----------------------------------------------------
ENTITY POKEMON IS
	PORT
	(
		IN_CLK           : IN  UINT01;
		IN_RST           : IN  UINT01;
		UP_SIG           : IN  UINT01;
		DOWN_SIG         : IN  UINT01;
		SELECT_SIG       : IN  UINT01;
		OUT_VGA_CLK      : OUT UINT01;
		R_VGA            : OUT UINT08;
		G_VGA            : OUT UINT08;
		B_VGA            : OUT UINT08;
		VGA_HS           : OUT UINT01;
		VGA_VS           : OUT UINT01
	);
END ENTITY VGA;
-----------------------------------------------------
ARCHITECTURE call OF POKEMON IS
SIGNAL GLOBAL_CLK   : UINT01;
SIGNAL GLOBAL_RST   : UINT01;
SIGNAL SEL_BAT_CONT : UINT01;
SIGNAL PK0_HIT_SIG  : UINT01;
SIGNAL PK1_HIT_SIG  : UINT01;
SIGNAL SELECTED_PK0 : UINT04;
SIGNAL SELECTED_PK1 : UINT04;
SIGNAL PK0_VISUAL   : UINT01;
SIGNAL PK1_VISUAL   : UINT01;
BEGIN
	
	OUT_VGA_CLK <= GLOBAL_CLK;

	IMAGE_CONTROL : ENTITY WORK.VGA
	PORT MAP
	(
		CLK              => IN_CLK      ,
		VGA_RST          => IN_RST      ,
		STATE_CONTROLLER => SEL_BAT_CONT,
		PK0_ANIM_SIG     => PK0_HIT_SIG ,
		PK1_ANIM_SIG     => PK1_HIT_SIG ,
		POKE0_SEL        => SELECTED_PK0,
		POKE1_SEL        => SELECTED_PK1,
		POKE0_ENA        => PK0_VISUAL  ,
		POKE1_ENA        => PK1_VISUAL  ,
		GLOBAL_RST       => GLOBAL_RST  ,
		VGA_CLK          => GLOBAL_CLK  ,
		R_VGA            => R_VGA       ,
		G_VGA            => G_VGA       ,
		B_VGA            => B_VGA       ,
		VGA_HS           => VGA_HS      ,
		VGA_VS           => VGA_VS      ,
	);
	
	GAME_CONTROL : ENTITY WORK.battle_engine
	PORT MAP
	(
		CLK        => GLOBAL_CLK,
		RST        => GLOBAL_RST,
		UP_SIG     => UP_SIG    ,
		DOWN_SIG   => DOWN_SIG  ,
		SELECT_SIG => SELECT_SIG,
	);
	
END ARCHITECTURE call;














