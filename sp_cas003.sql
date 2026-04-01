-- Analisis de la Cartera de Cobros para Determinar la separacion de las Polizas en 
-- Gestores, Cartera, Electronico e Incobrables
-- 
-- Creado    : 31/03/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/03/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

--drop procedure sp_cas003;

create procedure sp_cas003(a_compania CHAR(3), a_agencia char(3))
returning char(1),
          char(100),
	      char(20),
	      dec(16,2), 
	      char(50),
	      char(50),
	      smallint,
	      char(30),
	      char(50),
	      date,
	      date,
	      smallint,
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
		  char(10),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      smallint,
	      smallint,
	      char(5);

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _tipo_cas		char(1);
define _incobrable		smallint;
define _cod_formapag	char(3);
define _tipo_forma		smallint;
define a_fecha			date;
define _mes_contable    char(2);
define _ano_contable    char(4);
define _periodo         char(7);
define _saldo           dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define _cod_agente		char(5);
define _cobra_poliza	char(1);
define _cobra_poliza2	char(1);
define _cod_grupo		char(5);
define _nombre_grupo	char(50);
define _nombre_corredor	char(50);
define _nombre_cliente	char(100);
define _cod_cliente		char(10);
define _dia_cobros		smallint;
define _cedula			char(30);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _cod_tipoprod	char(3);
define _formapag        char(2);
define _vigencia_inic	date;
define _vigencia_final	date;
define _estatus_poliza	smallint;
define _monto           dec(16,2);
define _monto_pagado    dec(16,2);
define _montoTotal      dec(16,2);
define _montoPagado     dec(16,2);
define _saldo_vencer    dec(16,2);
define _saldo_exigible  dec(16,2);
define _saldo_corriente dec(16,2);
define _saldo_30        dec(16,2);
define _saldo_60        dec(16,2);
define _saldo_90        dec(16,2);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _cant_saldos		smallint;
define _cant_pagos		smallint;


--let a_fecha = today;
let a_fecha = mdy(3,31,2003);

let _ano_contable = year(a_fecha);

if month(a_fecha) < 10 then
	let _mes_contable = '0' || month(a_fecha);
else
	let _mes_contable = month(a_fecha);
end if

let _periodo = _ano_contable || '-' || _mes_contable;

{	
create temp table tmp_cas(
	tipo_cas		char(1),
	cliente			char(100),
	no_documento	char(20),
	saldo			dec(16,2),
	corredor		char(50),
	grupo			char(50)
	) with no log;
}

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where cod_compania = a_compania
    and actualizado  = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select incobrable,
	       cobra_poliza,
		   cod_pagador,
		   cod_grupo,
		   cod_formapag,
		   dia_cobros1,
		   cod_ramo,
		   cod_tipoprod,
		   vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   dia_cobros1,
		   dia_cobros2
	  into _incobrable,
	       _cobra_poliza2,
		   _cod_cliente,
		   _cod_grupo,
		   _cod_formapag,
		   _dia_cobros,
		   _cod_ramo,
		   _cod_tipoprod,
		   _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _dia_cobros1,
		   _dia_cobros2
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	let _monto_pagado = 0.00;

	foreach
	 select monto
	   into _monto
	   from cobredet
	  where doc_remesa   = _doc_poliza
	    and actualizado  = 1	   
	    and tipo_mov     IN ('P', 'N')
	    and periodo      = _periodo

		let _monto_pagado = _monto_pagado + _monto;
				
	end foreach

--	call sp_par78c(
	call sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 a_fecha
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    
   				 
	if _saldo        = 0 and
	   _monto_pagado = 0 then
		continue foreach;
	end if

	let _cant_saldos = 0;
	if _saldo <> 0 then
		let _cant_saldos = 1;
	end if

	let _cant_pagos = 0;
	if _monto_pagado <> 0 then
		let _cant_pagos = 1;
	end if

	let _saldo_vencer    = _por_vencer;
	let _saldo_exigible  = _exigible;
	let _saldo_corriente = _corriente;
	let _saldo_30        = _monto_30;
	let _saldo_60        = _monto_60;
	let _saldo_90        = _monto_90;

	LET _montoTotal      = _corriente + _monto_30 + _monto_60 + _monto_90 + _por_vencer;
	LET _montoPagado     = _monto_pagado;

	IF _montoTotal > 0 THEN

		IF _monto_90 <> 0 THEN

			IF _monto_90 >= _montoPagado THEN

				LET _monto_90    = _montoPagado;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_90;

			END IF	

		END IF

		IF _monto_60 <> 0 THEN

			IF _monto_60 >= _montoPagado THEN

				LET _monto_60    = _montoPagado;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_60;

			END IF	

		END IF

		IF _monto_30 <> 0 THEN

			IF _monto_30 >= _montoPagado THEN

				LET _monto_30    = _montoPagado;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_30;

			END IF	

		END IF
		
		IF _corriente <> 0 THEN

			IF _corriente >= _montoPagado THEN

				LET _corriente   = _montoPagado;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _corriente;

			END IF	

		END IF

		IF _por_vencer <> 0 THEN

			LET _por_vencer  = _montoPagado;
			LET _montoPagado = 0;

		END IF

		IF _montoPagado <> 0 THEN
			LET _corriente = _corriente + _montoPagado;
		END IF			

	ELSE

		LET _monto_90   = 0;
		LET _monto_60   = 0;
		LET _monto_30   = 0;
		LET _corriente  = _montoPagado;
		LET _por_vencer = 0;

	END IF

	LET _exigible = _corriente + _monto_30 + _monto_60 + _monto_90;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select nombre,
	       cedula
	  into _nombre_cliente,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select tipo_forma,
	       nombre[1,2]
	  into _tipo_forma,
	       _formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre
	  into _nombre_corredor
	  from agtagent
	 where cod_agente = _cod_agente;

--{
	if _tipo_forma = 5 then
		let _cobra_poliza = "E";
	elif _tipo_forma = 6 then
		let _cobra_poliza = "C";
	else
		let _cobra_poliza = _cobra_poliza2;
	end if
--}

{

	if _cobra_poliza = "A" then

		if _cod_agente = "00099" or
	       _cod_agente = "00731" or
	       _cod_agente = "00287" or
	       _cod_agente = "00557" or
	       _cod_agente = "00892" or
	       _cod_agente = "00238" or
	       _cod_agente = "00195" or
	       _cod_agente = "00778" or
	       _cod_agente = "00608" or
	       _cod_agente = "00433" or
	       _cod_agente = "00402" or
	       _cod_agente = "00488" or
	       _cod_agente = "00062" or
	       _cod_agente = "00846" or
	       _cod_agente = "00068" or
	       _cod_agente = "00632" or
	       _cod_agente = "00523" or
	       _cod_agente = "00286" or
	       _cod_agente = "00514" or
	       _cod_agente = "00033" or
	       _cod_agente = "00225" or
	       _cod_agente = "00021" or
	       _cod_agente = "00746" or
	       _cod_agente = "00674" or
	       _cod_agente = "00703" or
	       _cod_agente = "00207" or
	       _cod_agente = "00530" or
	       _cod_agente = "00628" or
	       _cod_agente = "00859" or
	       _cod_agente = "00767" or
	       _cod_agente = "00636" or
	       _cod_agente = "00761" or
	       _cod_agente = "00517" or
	       _cod_agente = "00622" or
	       _cod_agente = "00492" or
	       _cod_agente = "00562" or
	       _cod_agente = "00418" or
	       _cod_agente = "00662" or
	       _cod_agente = "00787" or
	       _cod_agente = "00279" or
	       _cod_agente = "00677" or
	       _cod_agente = "00734" or
	       _cod_agente = "00041" or
	       _cod_agente = "00166" or
	       _cod_agente = "00705" or
	       _cod_agente = "00234" or
	       _cod_agente = "00471" or
	       _cod_agente = "00780" or
	       _cod_agente = "00696" or
	       _cod_agente = "00243" or
	       _cod_agente = "00090" or
	       _cod_agente = "00071" or
	       _cod_agente = "00516" then

			let _cobra_poliza = "E";

		elif _cod_agente = "00269" or
		     _cod_agente = "00081" or
		     _cod_agente = "00547" or
		     _cod_agente = "00224" or
		     _cod_agente = "00008" or
		     _cod_agente = "00247" or
		     _cod_agente = "00248" or
		     _cod_agente = "00623" or
		     _cod_agente = "00012" or
		     _cod_agente = "00200" or
		     _cod_agente = "00815" or
		     _cod_agente = "00521" or
		     _cod_agente = "00727" or
		     _cod_agente = "00161" or
		     _cod_agente = "00146" or
		     _cod_agente = "00270" or
		     _cod_agente = "00540" or
		     _cod_agente = "00153" or
		     _cod_agente = "00133" or
		     _cod_agente = "00370" or
		     _cod_agente = "00035" or
		     _cod_agente = "00817" or
		     _cod_agente = "00119" or
		     _cod_agente = "00107" or
		     _cod_agente = "00037" or
		     _cod_agente = "00732" or
		     _cod_agente = "00001" or
		     _cod_agente = "00184" or
		     _cod_agente = "00235" or
		     _cod_agente = "00853" or
		     _cod_agente = "00125" or
		     _cod_agente = "00007" or
		     _cod_agente = "00180" or
		     _cod_agente = "00141" or
		     _cod_agente = "00567" then

			let _cobra_poliza = "C";

		end if

	end if

--}

{
	update emipomae
	   set cobra_poliza = _cobra_poliza
	 where no_poliza    = _no_poliza;
--}
	if _incobrable = 1 then
		let _tipo_cas = "4";
	else

		if _tipo_forma = 2 OR  
		   _tipo_forma = 4 THEN -- Tarjetas de Credito/Ach

			let _tipo_cas = "3";

		else

			if _cobra_poliza = "E" then -- Gestor
				
				let _tipo_cas = "1";

			elif _cobra_poliza = "C" then -- Corredor

				let _tipo_cas = "2";

			else -- Ambos

				let _tipo_cas = "5";

			end if

		end if
		
	end if

--	if _tipo_cas = "1" then
--		call sp_cob102(_cod_cliente, _dia_cobros1, _dia_cobros2, _doc_poliza);
--	end if

	return _tipo_cas,
	       _nombre_cliente,
		   _doc_poliza,
		   _saldo,
		   _nombre_corredor,
		   _nombre_grupo,
		   _dia_cobros,
		   _cedula,
		   _nombre_ramo,
		   _vigencia_inic,
		   _vigencia_final,
c		   _estatus_poliza,
		   _saldo_vencer,       
    	   _saldo_exigible,         
    	   _saldo_corriente,        
    	   _saldo_30,         
    	   _saldo_60,         
    	   _saldo_90,
		   _cod_cliente,
		   _por_vencer,       
    	   _exigible,         
    	   _corriente,        
    	   _monto_30,         
    	   _monto_60,         
    	   _monto_90,
		   _monto_pagado,
		   _cant_saldos,
		   _cant_pagos,
		   _cod_agente
		   with resume;

end foreach

end procedure
