-- Pasar Polizas que Cobra el Corredor con Modrosidad a 90 Dias
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas037;

create procedure sp_cas037(a_compania char(3), a_agencia char(3))
returning char(20),
          char(10),
		  char(100),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(5),
		  char(50),
		  char(3),
		  char(50),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cobra_poliza	char(1);
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _dia_temporal	smallint;
define _fecha_1_pago	date;
define _cod_pagador		char(10);
define _dia				smallint;

define _cod_cob_agt		char(3);
define _cod_formapag	char(3);
define _cod_agente		char(5);
define _cod_cobrador	char(3);
define _fecha			date;

define _cantidad		smallint;

define _nombre_cob_agt	char(50);
define _nombre_agente	char(50);
define _nombre_pagador	char(100);
define _nombre_compania	char(50);

define _saldo		    dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define a_fecha			date;
define _mes_contable    char(2);
define _ano_contable    char(4);
define _periodo         char(7);
define _error			integer;
define _cod_no_renov	char(3);
define _cod_ramo		char(3);

define _cant_cob		smallint;
define _loop			smallint;
define _dia_procesado	smallint;
define _vigencia_final	date;
define _cant_update		smallint;

--set debug file to "sp_cas037.trc";
set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania);

let a_fecha       = today;
let _ano_contable = year(a_fecha);

if month(a_fecha) < 10 then
	let _mes_contable = '0' || month(a_fecha);
else
	let _mes_contable = month(a_fecha);
end if

let _periodo = _ano_contable || '-' || _mes_contable;

let _cant_update = 0;

foreach
 select no_documento
   into	_no_documento
   from emipomae 
  where actualizado    = 1
	and cod_tipoprod   not in ("002", "004")
--	and estatus_poliza in (3)
--  and cod_formapag   = "004"
--	and no_documento   = "1802-00180-01"
--	and cod_pagador    = "19149"
  group by no_documento		

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
		   cobra_poliza,
		   estatus_poliza,
		   dia_cobros1,
		   dia_cobros2,
		   fecha_primer_pago,
		   cod_pagador,
		   cod_formapag,
		   cod_no_renov,
		   cod_ramo,
		   vigencia_final
	  into _cod_tipoprod,
		   _cobra_poliza,
		   _estatus_poliza,
		   _dia_cobros1,
		   _dia_cobros2,
		   _fecha_1_pago,
		   _cod_pagador,
		   _cod_formapag,
		   _cod_no_renov,
		   _cod_ramo,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

--	if _estatus_poliza <> 3 then
--		continue foreach;
--	end if

	if _cobra_poliza <> "C" then
		continue foreach;
	end if


{
	if _vigencia_final < "01/12/2002" or
	   _vigencia_final > "30/06/2003" then
		continue foreach;
	end if

	if _cod_pagador = "36403" or
	   _cod_pagador = "09678" or
	   _cod_pagador = "33105" or
	   _cod_pagador = "12107" or
	   _cod_pagador = "24893" or
	   _cod_pagador = "40259" or
	   _cod_pagador = "00066" or
	   _cod_pagador = "33607" or
	   _cod_pagador = "10285" or
	   _cod_pagador = "06281" or
	   _cod_pagador = "42175" or
	   _cod_pagador = "29764" or
	   _cod_pagador = "26043" or
	   _cod_pagador = "01249" or
	   _cod_pagador = "40313" or
	   _cod_pagador = "00164" or
	   _cod_pagador = "26020" or
	   _cod_pagador = "11050" or
	   _cod_pagador = "40587" or
	   _cod_pagador = "41412" or
	   _cod_pagador = "23801" or
	   _cod_pagador = "14763" or
	   _cod_pagador = "21774" or
	   _cod_pagador = "16446" then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from caspoliza
	 where no_documento = _no_documento;

	if _cantidad <> 0 then
		continue foreach;
	end if
}

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by cod_agente
		exit foreach;
	end foreach

	select cod_cobrador,
	       nombre
	  into _cod_cob_agt,
	       _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	-- Vencidas con saldo desde 01/12/2003

--	if _cod_cob_agt <> "026" then
--	if _cod_cob_agt <> "003" then
	if _cod_cob_agt <> "007" then
		continue foreach;
	end if


	-- Filtros para Gisela
{
	if _cod_cob_agt <> "007" then
		continue foreach;
	end if

	if _cod_pagador = "21099" or
	   _cod_pagador = "41071" or
	   _cod_pagador = "43068" or
	   _cod_pagador = "26772" or
	   _cod_pagador = "29441" or
	   _cod_pagador = "29440" or
	   _cod_pagador = "39302" or
	   _cod_pagador = "00727" or
	   _cod_pagador = "09754" or
	   _cod_pagador = "40864" or
	   _cod_pagador = "24687" or
	   _cod_pagador = "46301" or
	   _cod_pagador = "41506" or
	   _cod_pagador = "24612" or
	   _cod_pagador = "41211" or
	   _cod_pagador = "41246" then
		continue foreach;
	end if

}
	-- Filtros para Angelica
{
	if _cod_cob_agt <> "003" then
		continue foreach;
	end if

	if _cod_pagador = "42376" or
	   _cod_pagador = "41548" or
	   _cod_pagador = "40563" or
	   _cod_pagador = "41278" or
	   _cod_pagador = "32025" or
	   _cod_pagador = "08052" or
	   _cod_pagador = "51570" then
		continue foreach;
	end if
}

	call sp_cob33(
		 a_compania,
		 a_agencia,	
		 _no_documento,
		 _periodo,
		 a_fecha
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    


	if _saldo <= 0.00 then
		continue foreach;
	end if

{
	if _cod_cob_agt <> "026" then
		continue foreach;
	end if

	if _cod_pagador = "36403" or
	   _cod_pagador = "09678" or
	   _cod_pagador = "33105" or
	   _cod_pagador = "12107" or
	   _cod_pagador = "24893" or
	   _cod_pagador = "40259" or
	   _cod_pagador = "00066" or
	   _cod_pagador = "33607" or
	   _cod_pagador = "10285" or
	   _cod_pagador = "06281" or
	   _cod_pagador = "42175" or
	   _cod_pagador = "29764" or
	   _cod_pagador = "26043" or
	   _cod_pagador = "01249" or
	   _cod_pagador = "40313" or
	   _cod_pagador = "00164" or
	   _cod_pagador = "26020" or
	   _cod_pagador = "11050" or
	   _cod_pagador = "40587" or
	   _cod_pagador = "41412" or
	   _cod_pagador = "23801" or
	   _cod_pagador = "14763" or
	   _cod_pagador = "21774" or
	   _cod_pagador = "16446" then
		continue foreach;
	end if
}

{
	-- Canceladas con Saldo, Sin Incobrables

	if _cod_agente = "00007" or
	   _cod_agente = "00515" or
	   _cod_agente = "00271" or
	   _cod_agente = "00269" or
	   _cod_agente = "00184" or
	   _cod_agente = "00780" or
	   _cod_agente = "00799" or
	   _cod_agente = "00205" or
	   _cod_agente = "00454" or
	   _cod_agente = "00153" or
	   _cod_agente = "00370" then
		continue foreach;
	end if

	if _cod_pagador = "27091" or
	   _cod_pagador = "20555" or
	   _cod_pagador = "46359" or
	   _cod_pagador = "09681" or
	   _cod_pagador = "13000" or
	   _cod_pagador = "30033" or
	   _cod_pagador = "16928" or
	   _cod_pagador = "36403" or
	   _cod_pagador = "31931" or
	   _cod_pagador = "45561" or
	   _cod_pagador = "10087" or
	   _cod_pagador = "32448" or
	   _cod_pagador = "29087" or
	   _cod_pagador = "09327" or
	   _cod_pagador = "33119" or
	   _cod_pagador = "41700" or
	   _cod_pagador = "16359" then
		continue foreach;
	end if
}

--	if (_monto_90) <= 0.00 then
--		continue foreach;
--	end if

{

	-- Corredores de Sahily

	if _cod_cob_agt <> "026" then
		continue foreach;
	end if

	if _cod_agente <> "00243" then
		continue foreach;
	end if

	if _cod_agente = "00169" or
	   _cod_agente = "00270" or
	   _cod_agente = "00628" or
	   _cod_agente = "00153" or
	   _cod_agente = "00728" or
	   _cod_agente = "00180" then
		continue foreach;
	end if

	if _cod_pagador = "47919" or
	   _cod_pagador = "47932" or
	   _cod_pagador = "44774" or
	   _cod_pagador = "28547" or
	   _cod_pagador = "37402" or
	   _cod_pagador = "47156" or
	   _cod_pagador = "43598" or
	   _cod_pagador = "46919" or
	   _cod_pagador = "35642" or
	   _cod_pagador = "47154" or
	   _cod_pagador = "18110" or
	   _cod_pagador = "47134" or
	   _cod_pagador = "37684" or
	   _cod_pagador = "05318" or
	   _cod_pagador = "26723" or
	   _cod_pagador = "47155" or
	   _cod_pagador = "47318" or
	   _cod_pagador = "19851" or
	   _cod_pagador = "44445" or
	   _cod_pagador = "07806" or
	   _cod_pagador = "00806" or
	   _cod_pagador = "12068" or
	   _cod_pagador = "00908" or
	   _cod_pagador = "12472" or
	   _cod_pagador = "19873" then
		continue foreach;
	end if
}

{
	-- Corredores de Angelica

	if _cod_cob_agt <> "003" then
		continue foreach;
	end if

	if _cod_agente = "00623" or
	   _cod_agente = "00035" or
	   _cod_agente = "00235" then
		continue foreach;
	end if

	if _cod_agente = "00083" then
		if _cod_pagador = "20008" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00214" then
		if _cod_pagador = "00737" or
		   _cod_pagador = "41759" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00119" then
		if _cod_pagador = "28723" or
		   _cod_pagador = "01452" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00007" then
		if _cod_pagador = "16448" or
		   _cod_pagador = "12001" or
		   _cod_pagador = "11116" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00008" then
		if _cod_pagador = "32525" or
		   _cod_pagador = "45337" or
		   _cod_pagador = "40899" or
		   _cod_pagador = "36217" then
			continue foreach;
		end if
	end if
}

	-- Corredores de Gisela
{
	if _cod_agente = "00081" or
	   _cod_agente = "00221" or
	   _cod_agente = "00161" or
	   _cod_agente = "00034" or
	   _cod_agente = "00515" or
	   _cod_agente = "00036" or
	   _cod_agente = "00044" or
	   _cod_agente = "00845" or
	   _cod_agente = "00197" or
	   _cod_agente = "00141" then
		continue foreach;
	end if

	if _cod_agente = "00521" then
		if _cod_pagador = "44374" or
		   _cod_pagador = "44369" or
		   _cod_pagador = "44376" or
		   _cod_pagador = "44375" or
		   _cod_pagador = "44417" then
			continue foreach;
		end if
	end if


	if _cod_agente = "00218" then
		if _cod_pagador = "44556" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00176" then
		if _cod_pagador = "35980" then
			continue foreach;
		end if
	end if

	if _cod_agente = "00418" then
		if _cod_pagador = "30103" then
			continue foreach;
		end if
	end if
}

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select nombre
	  into _nombre_cob_agt
	  from cobcobra
	 where cod_cobrador = _cod_cob_agt;

--trace _no_documento;
--trace on;

{			  
	-- Pasar Datos al Call Center

	let _cant_update = _cant_update + 1;

	if _cant_update > 25 then
		exit foreach;
	end if

--	begin work;

	begin
	on exception set _error
--		rollback work;
	end exception


	if _dia_cobros1 > _dia_cobros2 then
		let _dia_temporal = _dia_cobros2;
		let _dia_cobros2  = _dia_cobros1;
		let _dia_cobros1  = _dia_temporal;
	end if

	if _dia_cobros1 <> _dia_cobros2 then
		if (_dia_cobros2 - _dia_cobros1) <= 10 then
			let _dia_cobros1 = _dia_cobros2;
		end if
	end if

	if _dia_cobros1 = 0 then
		let _dia_cobros1 = day(_fecha_1_pago);
		let _dia_cobros2 = day(_fecha_1_pago);
	end if

	call sp_cob102(_cod_pagador, _dia_cobros1, _dia_cobros2, _no_documento);

	-- Determinar el Cobrador para los registros del call center dependiendo del area

	call sp_cas007();

	select cod_cobrador
	  into _cod_cobrador
	  from cascliente
	 where cod_cliente = _cod_pagador;

	select fecha_ult_pro
	  into _fecha
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	let _fecha = _fecha + 2;
	let _dia   = day(_fecha);

	let _dia_procesado = 0;

	for _loop = 1 to 31 
	
		let _cant_cob = sp_cas045(_cod_cobrador, _dia);
	
		if _cant_cob <= 80 then

			let _dia_procesado = 1;
			
			update cascliente
			   set dia_cobros3 = _dia
			 where cod_cliente = _cod_pagador;

			call sp_cas001(_cod_pagador);

			update emipomae
			   set cobra_poliza = "E",
			       cod_formapag = "006"
		     where no_poliza    = _no_poliza;

			exit for;

		end if

		let _fecha = _fecha + 1;
		let _dia   = day(_fecha);

	end for

	if _dia_procesado = 0 then

		select fecha_ult_pro
		  into _fecha
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;

		let _fecha = _fecha + 2;
		let _dia   = day(_fecha);

		update cascliente
		   set dia_cobros3 = _dia
		 where cod_cliente = _cod_pagador;

		call sp_cas001(_cod_pagador);

		update emipomae
		   set cobra_poliza = "E",
		       cod_formapag = "006"
	     where no_poliza    = _no_poliza;

	end if

	end

	--rollback work;
--	commit work;

--}

--trace off;

	return _no_documento,
		   _cod_pagador,	
	       _nombre_pagador,
		   _saldo,
		   _por_vencer,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _cod_agente,
		   _nombre_agente,
		   _cod_cob_agt,
		   _nombre_cob_agt,
		   _nombre_compania
		   with resume;

end foreach

end procedure