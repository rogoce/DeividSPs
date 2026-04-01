-- Cargar Porcentajes de Gasto de Administracion, Adquisicion y Contrato XLS
-- 
-- Creado    : 08/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_sis47;

CREATE PROCEDURE "informix".sp_sis47()

define _cod_ramo			char(3);
define _ano					smallint;
define _periodo				char(4);

define _porc_gasto_admin	dec(16,2);
define _porc_gasto_adquis	dec(16,2);
define _porc_xls			dec(16,2);

{
FOR _ano = 1990 TO 2004
	
	let _periodo = _ano;

	foreach
	 select cod_ramo
	   into _cod_ramo
	   from prdramo

		insert into parporga
		values (_cod_ramo, _periodo, 0.00, 0.00, 0.00);

	end foreach

END FOR
}

-- Actualizar los % para los Calculos de los Resultados Tecnicos

foreach with hold
 select cod_ramo,
        periodo
   into _cod_ramo,
        _periodo
   from parporga

	let _porc_gasto_admin  = 0.0;
	let _porc_gasto_adquis = 0.0;
	let _porc_xls          = 0.0;

	if _periodo <= "1999" then

		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 17.1;
			let _porc_gasto_adquis =  0.9;
			let _porc_xls          = 17.0;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 17.3;
			let _porc_gasto_adquis =  2.8;
			let _porc_xls          =  0.5;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 3.9;
			let _porc_gasto_adquis = 0.6;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 4.0;
			let _porc_gasto_adquis = 0.1;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 9.4;
			let _porc_gasto_adquis = 2.9;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 17.9;
			let _porc_gasto_adquis = 0.7;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 18.7;
			let _porc_gasto_adquis = 3.0;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 38.8;
			let _porc_gasto_adquis = 0.0;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 314.5;
			let _porc_gasto_adquis = 10.6;
			let _porc_xls          = 0.0;

		end if
	
	elif _periodo = "2000" then
	 
		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 14.4;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 11.6;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 15.7;
			let _porc_gasto_adquis = 3.9;
			let _porc_xls          = 1.2;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 6.7;
			let _porc_gasto_adquis = 1.2;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 22.5;
			let _porc_gasto_adquis = 2.6;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 12.6;
			let _porc_gasto_adquis = 1.7;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 18.0;
			let _porc_gasto_adquis = 0.9;
			let _porc_xls          = 12.4;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 14.9;
			let _porc_gasto_adquis = 0.8;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 28.9;
			let _porc_gasto_adquis = 2.3;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 431.6;
			let _porc_gasto_adquis = 35.5;
			let _porc_xls          = 0.0;

		end if

	elif _periodo = "2001" then

		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 13.4;
			let _porc_gasto_adquis = 1.4;
			let _porc_xls          = 14.1;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 16.8;
			let _porc_gasto_adquis = 5.4;
			let _porc_xls          = 1.7;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 10.7;
			let _porc_gasto_adquis = 2.5;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 17.0;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 14.4;
			let _porc_gasto_adquis = 1.6;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 17.4;
			let _porc_gasto_adquis = 0.6;
			let _porc_xls          = 11.3;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 15.7;
			let _porc_gasto_adquis = 0.1;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 25.4;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 94.7;
			let _porc_gasto_adquis = 5.2;
			let _porc_xls          = 0.0;

		end if

	elif _periodo = "2002" then

		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 15.0;
			let _porc_gasto_adquis = 1.4;
			let _porc_xls          = 34.6;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 18.8;
			let _porc_gasto_adquis = 4.2;
			let _porc_xls          = 2.2;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 12.7;
			let _porc_gasto_adquis = 2.7;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 20.8;
			let _porc_gasto_adquis = 1.6;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 13.6;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 19.2;
			let _porc_gasto_adquis = 1.3;
			let _porc_xls          = 12.2;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 14.0;
			let _porc_gasto_adquis = 0.1;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 22.3;
			let _porc_gasto_adquis = 1.9;
			let _porc_xls          = 6.6;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 52.2;
			let _porc_gasto_adquis = 7.7;
			let _porc_xls          = 0.0;

		end if

	elif _periodo = "2003" then

		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 13.1;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 38.8;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 16.7;
			let _porc_gasto_adquis = 6.4;
			let _porc_xls          = 2.0;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 12.2;
			let _porc_gasto_adquis = 2.7;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 21.4;
			let _porc_gasto_adquis = 1.2;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 15.7;
			let _porc_gasto_adquis = 1.1;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 21.3;
			let _porc_gasto_adquis = 1.6;
			let _porc_xls          = 17.9;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 13.1;
			let _porc_gasto_adquis = 1.3;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 21.6;
			let _porc_gasto_adquis = 3.5;
			let _porc_xls          = 8.9;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 51.9;
			let _porc_gasto_adquis = 4.7;
			let _porc_xls          = 0.0;

		end if

	elif _periodo = "2004" then

		if _cod_ramo = "001" or	   -- Inc
		   _cod_ramo = "003" then  -- Multi

			let _porc_gasto_admin  = 12.8;
			let _porc_gasto_adquis = 1.0;
			let _porc_xls          = 30.5;

		elif _cod_ramo = "002" then	-- Auto

			let _porc_gasto_admin  = 15.6;
			let _porc_gasto_adquis = 6.4;
			let _porc_xls          = 1.5;

		elif _cod_ramo = "004" or   -- AP
		     _cod_ramo = "016" then -- CV

			let _porc_gasto_admin  = 10.4;
			let _porc_gasto_adquis = 2.7;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "005" or
		     _cod_ramo = "006" or
		     _cod_ramo = "007" or
		     _cod_ramo = "015" or
		     _cod_ramo = "017" then	 -- Varios

			let _porc_gasto_admin  = 16.9;
			let _porc_gasto_adquis = 1.2;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "008" or
		     _cod_ramo = "080" then	-- Fianzas

			let _porc_gasto_admin  = 9.8;
			let _porc_gasto_adquis = 1.1;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "009" then	-- Carga

			let _porc_gasto_admin  = 17.4;
			let _porc_gasto_adquis = 1.6;
			let _porc_xls          = 12.0;

		elif _cod_ramo = "010" or
		     _cod_ramo = "011" or
		     _cod_ramo = "012" or
		     _cod_ramo = "013" or
		     _cod_ramo = "014" then -- Tecnicos

			let _porc_gasto_admin  = 8.1;
			let _porc_gasto_adquis = 1.3;
			let _porc_xls          = 0.0;

		elif _cod_ramo = "018" then	-- Salud

			let _porc_gasto_admin  = 16.2;
			let _porc_gasto_adquis = 3.5;
			let _porc_xls          = 10.0;

		elif _cod_ramo = "019" then -- VI

			let _porc_gasto_admin  = 29.6;
			let _porc_gasto_adquis = 4.7;
			let _porc_xls          = 0.0;

		end if

	end if

	update parporga
	   set porc_gasto_admin  = _porc_gasto_admin,
	       porc_gasto_adquis = _porc_gasto_adquis,
		   porc_xls          = _porc_xls
	 where cod_ramo          = _cod_ramo
	   and periodo           = _periodo;

end foreach

end procedure
