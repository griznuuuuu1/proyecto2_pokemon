LIBRARY IEEE               ;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL   ;
-----------------------------------
LIBRARY PLL_40MHz          ;
USE PLL_40MHz.ALL          ;
USE WORK.basic_package.ALL ;
USE WORK.VGA_package.ALL   ;
-----------------------------------------------------
ENTITY VGA IS
	PORT
	(
		CLK              : IN  UINT01;
		VGA_RST          : IN  UINT01;
--		LEFT_SIG         : IN  UINT01;
		STATE_CONTROLLER : IN  UINT01;

		PK0_ANIM_SIG     : IN  UINT01;
		PK1_ANIM_SIG     : IN  UINT01;
		POKE0_SEL        : IN  UINT04;
		POKE1_SEL        : IN  UINT04;
		POKE0_ENA        : IN  UINT01;
		POKE1_ENA        : IN  UINT01;
		P0_HP            : IN  UINT08;
		P1_HP            : IN  UINT08;
		GLOBAL_RST       : OUT UINT01;
		VGA_CLK          : OUT UINT01;
		R_VGA            : OUT UINT08;
		G_VGA            : OUT UINT08;
		B_VGA            : OUT UINT08;
		VGA_HS           : OUT UINT01;
		VGA_VS           : OUT UINT01
	);
END ENTITY VGA;
-----------------------------------------------------
ARCHITECTURE call OF VGA IS
SIGNAL VIDEO_ENA    : UINT01  ;
SIGNAL CLK_40MHz    : UINT01  ;
SIGNAL PLL_LOCKED   : UINT01  ;
SIGNAL GLB_RST      : UINT01  ;
SIGNAL S0_POS_X     : UINT11  ;
SIGNAL S0_POS_Y     : UINT11  ;
SIGNAL S1_POS_X     : UINT11  ;
SIGNAL S1_POS_Y     : UINT11  ;
SIGNAL POS_X        : UINT11  ;
SIGNAL POS_Y        : UINT11  ;
SIGNAL P0_HP_INT    : INTEGER RANGE 0 TO 255;
SIGNAL P1_HP_INT    : INTEGER RANGE 0 TO 255;
BEGIN
	
	MOVE_CONT : ENTITY WORK.move_controller
	PORT MAP
	(
		CLK           => CLK_40MHz       ,
		RST           => GLB_RST         ,
		STATE_CONT    => STATE_CONTROLLER,
		PK0_MOV_CONT  => PK0_ANIM_SIG    ,
		PK1_MOV_CONT  => PK1_ANIM_SIG    ,
		SP0_X         => S0_POS_X        ,
		SP0_Y         => S0_POS_Y        ,
		SP1_X         => S1_POS_X        ,
		SP1_Y         => S1_POS_Y  
	);
	
	GLOBAL_RST <= GLB_RST;
	
	VGA_CLK    <= CLK_40MHz            ;
	GLB_RST <= (NOT PLL_LOCKED) OR VGA_RST;
	
	CLOCK_BLOCK : ENTITY PLL_40MHz.PLL_40MHz
	PORT MAP
	(
		refclk   => CLK       ,
		rst      => VGA_RST   ,
		outclk_0 => CLK_40MHz ,
		locked   => PLL_LOCKED
	);
	
	SYNC_BLOCK : ENTITY WORK.image_sync
	PORT MAP
	(
		RESET    => GLB_RST   ,
		SYNC_CLK => CLK_40MHz ,
		H_SYNC   => VGA_HS    ,
		V_SYNC   => VGA_VS    ,
		VIDEO_ON => VIDEO_ENA ,
		PIXEL_X  => POS_X     ,
		PIXEL_Y  => POS_Y
	);
	
	COLOR_BLOCK : ENTITY WORK.pixel_generate
	PORT MAP
	(
		CLK           => CLK_40MHz,
		SPRITE0_POS_X => S0_POS_X ,
		SPRITE0_POS_Y => S0_POS_Y ,
		SPRITE1_POS_X => S1_POS_X ,
		SPRITE1_POS_Y => S1_POS_Y ,
		POS_X         => POS_X    ,
		POS_Y         => POS_Y    ,
		PK0_SELECTOR  => POKE0_SEL,
		PK1_SELECTOR  => POKE1_SEL,
		POKEMON0_ENA  => POKE0_ENA,
		POKEMON1_ENA  => POKE1_ENA,
		VIDEO_ON      => VIDEO_ENA,
		P0_HP         => P0_HP    ,
		P1_HP         => P1_HP    ,
		R             => R_VGA    ,
		G             => G_VGA    ,
		B             => B_VGA
	);
	
END ARCHITECTURE call;















