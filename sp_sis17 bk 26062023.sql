
create procedure sp_sis17(a_no_poliza char(10))
returning integer;

define _nombre_pagad		char(100);
define _mensaje				char(100);
define _error_desc			char(50);
define _no_motor			char(30);
define _reemplaza_poliza	char(20);
define _no_documento		char(20);
define _no_doc_orig			char(20);
define _no_factura			char(20);
define _no_recibo			char(20);
define _no_tarjeta			char(19);
define _no_cuenta			char(17);
define _cod_contratante		char(10);
define _no_poliza_ren		char(10);
define _no_fac_orig			char(10);
define _cod_pagador			char(10);
define _placa				char(10);
define _no_p				char(10);
define _user_added			char(8);
define ls_periodo_contable	char(7);
define ls_periodo_vi		char(7);
define _fecha_exp			char(7);
define _periodo				char(7);
define _no_endoso_ext		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_compania		char(3);
define _cod_formapag		char(3);
define _cod_sucursal		char(3);
define _cod_tipoprod		char(3);
define _sucursal_web		char(3);
define _cod_perpago			char(3);
define _cod_endomov			char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _cod_banco			char(3);
define _cod_cobrador		char(3);  
define _cod_ramo,_est_lic   char(3);  
define _cobra_poliza		char(1);
define _tipo_tarjeta		char(1);
define _periodo_visa		char(1);
define _nueva_renov			char(1);
define _tipo_cuenta			char(1);
define _gestion,_tip_agt	char(1);
define _null				char(1);
define _prima_sus_sum		dec(9,6);
define _prima_sus_cal		dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_emif, _suma_emif dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _monto_visa			dec(16,2);
define _monto_desc          dec(16,2);
define _flag_electronico	smallint;
define _tipo_produccion		smallint;
define _saldo_x_unidad		smallint;
define _cantidad_uni		smallint;
define _cnt_emifafac		smallint;
define _desc_electr			smallint;
define _declarativa			smallint;
define _dia_cobros1			smallint;
define _multipoliza         smallint;
define _dias_grupo			smallint;
define _tipo_forma			smallint;
define _cant_fact			smallint;
define _mala_refe			smallint;
define _tiene_imp			smallint;
define _cnt_serie			smallint;
define _cantidad			smallint;
define _fronting			smallint;
define _ramo_sis			smallint;
define _cnt_reas			smallint;
define _return				smallint;
define _error,_cnt_cam		smallint; 
define _cnt,_coope			smallint;
define _canti,_importado	smallint;
define _no_pagos			integer;
define _serie				integer;
define _fecha_indicador		date;
define _fecha_1_pago		date;
define _vig_i				date;
define _fecha_hoy           date;
define _cnt_existe,_nuevo	smallint;
define _par_grupo			char(18);
define _li_auto             smallint;
define _tipo_ramo           smallint;
define _vida				smallint;
define _general				smallint;
define _fianza				smallint;
set isolation to dirty read;

let _null      = null;
let _no_endoso = '00000';
let _fronting  = 0;
let _mala_refe = 0;
let _prima_emif = 0;
let _suma_emif  = 0;
let _reemplaza_poliza = "";
let _fecha_hoy = current;
let _par_grupo = "";
let _cnt_existe = 0;
let _error = 0;
let _importado = 0;
let _cnt_cam   = 0;
let _est_lic = '';

if a_no_poliza = '0001897613' then
	set debug file to "sp_sis17.trc";
	trace on;
end if

begin
on exception set _error 
 	return _error;         
end exception           

let _cod_endomov = "011";
let _no_doc_orig = null;
let _no_fac_orig = null;
let _canti       = 0;
let _saldo_x_unidad   = 0;
let _reemplaza_poliza = "";
select cod_compania,
	   cod_sucursal,
	   nueva_renov,
	   no_documento,
	   no_factura,
	   no_tarjeta,
	   fecha_exp,
	   cod_banco,
	   user_added,
	   cod_pagador,
	   dia_cobros1,
	   cod_formapag,
	   tipo_tarjeta,
	   cod_perpago,
	   cod_contratante,
	   no_pagos,
	   prima_bruta,
	   fecha_primer_pago,
	   no_cuenta,
	   tipo_cuenta,
	   cod_tipoprod,
	   cod_origen,
	   cobra_poliza,
	   cod_ramo,
	   saldo_por_unidad,
	   vigencia_inic,
	   periodo,
	   reemplaza_poliza,
	   tiene_impuesto,
	   no_recibo,
	   cod_subramo,
	   cod_grupo,
	   declarativa,
	   suma_asegurada,
	   prima_neta
	--   multipoliza
  into _cod_compania,
	   _cod_sucursal,
	   _nueva_renov,
	   _no_doc_orig,
	   _no_fac_orig,
	   _no_tarjeta,
	   _fecha_exp,
	   _cod_banco,
	   _user_added,
	   _cod_pagador,
	   _dia_cobros1,
	   _cod_formapag,
	   _tipo_tarjeta,
	   _cod_perpago,
	   _cod_contratante,
	   _no_pagos,
	   _prima_bruta,
	   _fecha_1_pago,
	   _no_cuenta,
	   _tipo_cuenta,
	   _cod_tipoprod,
	   _cod_origen,
	   _cobra_poliza,
	   _cod_ramo,
	   _saldo_x_unidad,
	   _vig_i,
	   _periodo,
	   _reemplaza_poliza,
	   _tiene_imp,
	   _no_recibo,
	   _cod_subramo,
	   _cod_grupo,
	   _declarativa,
	   _suma_asegurada,
	   _prima_neta
	--   _multipoliza
  from emipomae
 where no_poliza = a_no_poliza;
if (_nueva_renov = 'N') And (_cod_ramo = '018' And _cod_subramo <> '012') then --ComisiÃ³n PÃ³lizas de Salud Suscritas por Cambio de Plan debe ser 10%, Analisa 26/06/2019
	IF _reemplaza_poliza <> "" or _reemplaza_poliza is not null then
		let _cnt_cam = 0;
		let _cnt_cam = sp_bo077b(_reemplaza_poliza);	--Busca si tiene cambio de plan.
	END IF
end if
--Validacion del corredor vs el ramo -- Amado Perez 27-04-2023
select b.tipo_ramo
  into _tipo_ramo
  from prdramo a, prdtiram b 
 where a.cod_tiporamo = b.cod_tiporamo
   and a.cod_ramo = _cod_ramo; 
--Validacion de licencia de corredor, puesto en produccion 11/04/2019
foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		 
		 select estatus_licencia,
		        tipo_agente,
		        vida,
			    general,
			    fianzas
		   into _est_lic,
		        _tip_agt,
		        _vida,
			    _general,
			    _fianza
		   from agtagent
		  where cod_agente = _cod_agente;
		  
        if _est_lic = "P" then	--suspendido permanentemente, no puede emitir polizas.
		    let _error = 243;
		end if
		if _cnt_cam = 1 and _tip_agt <> 'O' then
			update emipoagt
			   set porc_comis_agt = 10
			 where no_poliza  = a_no_poliza
			   and cod_agente = _cod_agente;
		end if
		if _tipo_ramo = 1 And _vida = 0 Then --No puede emitir pÃ³lizas por el tipo de licencia
			let _error = 244;
		end if
		if _tipo_ramo = 2 And _general = 0 Then
			let _error = 244;
		end if
		if _tipo_ramo = 3 And _fianza = 0 Then
			let _error = 244;
		end if		
end foreach
if _error = 243 or _error = 244 then
	return _error;
end if
if _user_added = 'EVALUACI' then	--28/12/2018, No se debe actualizar una poliza con este usuario, produccion tiene el programa para asignar al usuario.
	return 33;
end if

{if _no_doc_orig <> '1819-99900-01' then
--set debug file to "sp_sis17.trc";
--trace on;
	RETURN 2;
end if}

select valor_parametro
  into _sucursal_web
  from inspaag
 where codigo_compania 	= "001"
   and codigo_agencia  	= "001"
   and aplicacion      	= "PRO"
   and version         	= "02"
   and codigo_parametro	= "sucursal_web";

if _cod_grupo = '00087' then --Grupo FINCAP
	let _par_grupo = "dias_fincap";
elif _cod_grupo = '1090' then --Grupo SCOTIABANK
	let _par_grupo = "dias_scotiabank";
elif _cod_grupo = '124' or _cod_grupo = '125' then --Grupo BANISI
	let _par_grupo = "dias_banisi";
	let _no_pagos = 12;              -- se cambia a 12Pagos desde 04/Feb/2019 1:41 PM ASTANZIO
elif _cod_grupo = '1122' then  -- Grupo BANISI - DUCRUET, F9: 30295 falta enviar el convenio 15/01/2019 ASTANZIO  
	let _par_grupo = "dias_banisi";   
	let _no_pagos = 12;
end if

if _par_grupo <> '' then
	let _dias_grupo = 0;

	select valor_parametro
	  into _dias_grupo
	  from inspaag
	 where codigo_compania = "001"
	   and codigo_agencia = "001"
	   and aplicacion = "COB"
	   and version = "02"
	   and codigo_parametro	= _par_grupo;

	let _fecha_1_pago = _fecha_1_pago + _dias_grupo units day;
end if

-- 	VerificaciÃ³n de el campo de reemplaza poliza --Federico 06/02/2020
-- 	_error 327 el nÃºmero de motor que desea emitir esta incluido en una pÃ³liza que fue cancelada para ser reemplazada debe llenar el campo reemplaza pÃ³liza.
if _cod_ramo in('002','020') and _cod_sucursal <> _sucursal_web and _nueva_renov = 'N' then
	CALL sp_emi02(a_no_poliza) returning _error, _error_desc; 
	if _error <> 0 then
		return _error;
	end if
end if

foreach
	select serie
	  into _serie
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
	   and _vig_i between vig_inic and vig_final
	exit foreach;
end foreach
if _cod_sucursal = _sucursal_web then -- sucursal web ?  --and _cod_ramo <> '003'
	foreach
		select serie
		  into _serie
		  from rearumae
		 where cod_ramo = _cod_ramo
		   and activo   = 1
		   and _vig_i between vig_inic and vig_final
		   and ruta_web = 1
	 exit foreach;
	end foreach
	{if _cod_ramo = '020' then
		if _reemplaza_poliza <> "" or _reemplaza_poliza is not null then
		else
			CALL sp_sis107(a_no_poliza) returning _error, _error_desc;

			SELECT periodo
			  INTO _periodo
			  FROM emipomae
			 WHERE no_poliza = a_no_poliza;	

			if _error <> 0 then
				return _error;
			end if
		end if
	else}
	if _nueva_renov = 'N' then
		if _cod_grupo not in("00000","1000") then --Estado No
			select mala_referencia into _mala_refe from cliclien where cod_cliente = _cod_contratante;	--*****CLIENTES CON MALA REFRENCIA NO PUEDEN EMITIR POLIZAS NUEVAS 29/03/2017
			if _mala_refe is null then
				let _mala_refe = 0;
			end if
			let _li_auto = sp_par377(_cod_contratante); -- Procedimiento para buscar clientes con mala referencia para auto -- Amado 08/08/2022
			if _mala_refe <> 0 and _li_auto = 0 then
				return 10;
			end if
			if _mala_refe <> 0 and _li_auto = 1 and _cod_ramo in ('002','020') then
				return 10;
			end if
		end if	
		call sp_sis107(a_no_poliza) returning _error, _error_desc;

		if _error <> 0 then
			return _error;
		end if
	end if
   --end if
end if
-- Polizas Nuevas de Soda con 
-- Forma de Pago Ancon 
-- Numero de Recibo es Obligatorio
-- Solicitud del 24/06/2013 
-- Puesta en Produccion el 25/06/2013
-- Demetrio Hurtado Almanza
-- Se puso en comentario 29/12/2014, Armando Moreno.
{if _nueva_renov  = 'N'    and
   _cod_ramo     = "020"  and
   _cod_formapag = "006"  and
   _no_recibo    is null then
	return 5;
end if}

-- Polizas Nuevas y renovaciones de Soda con 
-- Forma de Pago diferente de 008 (corredor Remesa)
-- Numero de Recibo es Obligatorio
-- Adecuaciones auto
-- Puesta en Produccion el 29/12/2014
-- Armando Moreno.
--se excluye las polizas de la web debido a que no se coloca recibo.
let _no_recibo = trim(_no_recibo);
if (_no_recibo is null or _no_recibo = "") and _cod_sucursal <> '009' And _cod_ramo = "020" and _cod_formapag not in ("008","095") then
	return 5;
end if
if _cod_formapag = "005" then --Forma de pago ACH
    let _coope = null;
	select cooperativa into _coope from chqbanco where cod_banco = _cod_banco;
    if _coope = 1 then
		return 325; --Para Formas de Pago Ach, No se puede emitir con cooperativas, Nimia Solis. puesto en prod. 07/05/2018
	end if
end if
select count(*)
  into _cnt
  from emipoagt
 where no_poliza = a_no_poliza;
if _cnt is null then
	let _cnt = 0;
end if
if _cod_formapag = "008" And _cnt = 1 then --and _cod_ramo = "020" then -- solo ramo soda solicitado por analisa.
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		 
		 select cod_cobrador
		   into _cod_cobrador
		   from agtagent
		  where cod_agente = _cod_agente;
		  
        if _cod_cobrador = "217" then
		    let _error = 1;
			exit foreach;
		end if
	end foreach
elif _cod_formapag = "006" And _cnt = 1 then
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		 
		 select cod_cobrador
		   into _cod_cobrador
		   from agtagent
		  where cod_agente = _cod_agente;
		  
        if _cod_cobrador <> "217" then
		    let _error = 1;
			exit foreach;
		end if
	end foreach
end if
if _error = 1 then
	return 322; --El Corredor No puede usar esta forma de pago, verifique.
end if
--Vehiculos bloqueados no se pueden emitir ni renovar	Armando
let _error = sp_sis419(a_no_poliza);
if _error = 1 then
	return 9;
end if
-- % de comision de agentes tipo Oficina debe ser cero, y verifica
-- que el % de participacion sume 100.00
-- Puesta en Produccion el 27/06/2013
-- Armando Moreno M.
call sp_sis407(a_no_poliza) returning _error, _mensaje;
if _error <> 0 then
	return _error;
end if
-- ExcepciÃ³n para el caso 2168 CODIGO 324 / EMISION POLIZA DE INCENDIO esta pÃ³liza nueva se va emitir bajo autorizaciÃ³n previa de la vicepresidencia WE 30/12/2021 --Amado Perez M.
if a_no_poliza <> '0001730812' then
	if _cod_ramo in('001','003') And _nueva_renov = 'N' then	--Para incendio y Multiriesgo con vigencias >= 01/07/2018 en Z.L. y FF, no se puede emitir. 07/05/2018
																--Se cambia para que no se pueda emitir nuevas y se quita lo de la vigencia. 31/05/2018 10:30 am
		select count(*)
		  into _cnt
		  from emipouni u, emiman05 e
		 where u.cod_manzana = e.cod_manzana
		   and u.no_poliza = a_no_poliza
		   and e.cod_barrio in('0103','4400'); --Barrio Zona L. y Barrio France Field
		if _cnt > 0 then
			return 324;
		end if
		if _cod_subramo in('005','006') then
			return 324;
		end if
	end if
end If
if _nueva_renov = 'R' then
	call sp_sis186(_no_doc_orig,_tiene_imp) returning _error;
	if _error <> 0 then
		return 3;
	end if
	select mala_referencia into _mala_refe from cliclien where cod_cliente = _cod_contratante;
	if _mala_refe <> 0 and _cod_ramo in ('002','020') then
		let _li_auto = sp_par377(_cod_contratante); -- Procedimiento para buscar clientes con mala referencia para auto -- Amado 08/08/2022
		if _li_auto = 1 then
			return 10;
		end if
	end if			
else
	if _cod_ramo = '018' and day(_vig_i) > 28 then
		return 8;
	end if
	--***********VALIDACION PARA CLIENTES CON MALA REFERENCIA POLIZAS NUEVAS NO PUEDEN EMITIR 29/03/2017 auditoria
	if _cod_grupo not in("00000","1000") then --Estado No
		select mala_referencia into _mala_refe from cliclien where cod_cliente = _cod_contratante;
		if _mala_refe is null then
			let _mala_refe = 0;
		end if
		let _li_auto = sp_par377(_cod_contratante); -- Procedimiento para buscar clientes con mala referencia para auto -- Amado 08/08/2022
		if _mala_refe <> 0 and _li_auto = 0 then
			return 10;
		end if
		if _mala_refe <> 0 and _li_auto = 1 and _cod_ramo in ('002','020') then
			return 10;
		end if		
	end if
	if _cod_ramo in ('002','020','023') and _cod_tipoprod <> '002' then	--se puso exclusion de coas. min por las cargas del estado, Jenniffer de F.
		foreach
			select no_motor
			  into _no_motor
			  from emiauto
			 where no_poliza = a_no_poliza

			if a_no_poliza = '0001229877' then
				exit foreach;
			end if	

			if _no_motor is null then
				let _no_motor = '';
			end if
			if _no_motor = '' then
				return 323;
			end if
			let _nuevo = 0;
			select placa,nuevo,importado
			  into _placa,_nuevo,_importado
			  from emivehic
			 where no_motor = _no_motor;
			if _importado is null then
				let _importado = 0;
			end if
			if _placa is null then
				let _placa = '';
			end if
			if _placa = '' And _nuevo <> 1 And _importado <> 1 then
				return 323;
			end if
			let _error = sp_sis21b(_placa);
			if _error = 1 And _nuevo <> 1 And _importado <> 1 then
				return 323;
			end if
		end foreach
	end if
end if
select tipo_forma
  into _tipo_forma
  from cobforpa
 where cod_formapag = _cod_formapag;

select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _tipo_produccion = 3 then
	select count(*)
	  into _cnt
	  from emicoami
	 where no_poliza = a_no_poliza;

	if _cnt = 0 then
		return 1;
	end if
end if
--Actualizar el periodo contable***************
select emi_periodo
  into ls_periodo_contable
  from parparam
 where cod_compania = '001';
 
let ls_periodo_vi   = sp_sis39(_vig_i);

if ls_periodo_vi > ls_periodo_contable then
	let ls_periodo_contable = ls_periodo_vi;
end if
update emipomae
   set periodo   = ls_periodo_contable
 where no_poliza = a_no_poliza;
--*********************************************
if _nueva_renov = 'N' then
	if _no_doc_orig is null then
	    if _cod_sucursal = '' then
			return 2;
		end if
 	 	let _no_documento = sp_sis19(_cod_compania, _cod_sucursal, a_no_poliza);  
 	else                                                                          
 		let _no_documento = _no_doc_orig;                                         
 	end if
	
	{if _multipoliza <> 1 then}
		select count(*) 
		  into _canti 
		  from emipomae 
		 where actualizado = 1 
		   and no_documento = _no_documento;

		if _canti > 0 then
			return 1;
		end if
	{end if	}
	let _cobra_poliza = "2"; --antes "A"
	if _tipo_forma = 2 then -- Tarjetas de Credito 
		let _cobra_poliza = "4"; --antes "T"
	end if
	if _tipo_forma = 4 THEN -- ACH
		let _cobra_poliza = "4"; --antes "H"
	end if
	if _cod_ramo = '019' then --anos_pagador = 1 ramo vida individual cuando la poliza es nueva

		update emipomae
		   set anos_pagador = 1
		 where no_poliza    = a_no_poliza;

	{elif _cod_ramo = '020' then
		if _reemplaza_poliza <> "" or _reemplaza_poliza is not null then
			let _no_p = sp_sis21(_reemplaza_poliza);
			if _no_p <> "" or _no_p is not null then
				update emipomae
				   set reemplaza_poliza = _no_documento
				 where no_poliza = _no_p;
			end if
			
		end if}
	end if

	call sp_sis64(_no_documento);  --inserta emipoliza si no existe.

	if _fecha_hoy < '01/02/2016' then
		if _cod_ramo = '018' then		   --inserta chqcomsa si no existe. (para bono de 100 por c/4 polizas de salud emitidas)
			call sp_sis422(_no_documento,a_no_poliza);
		end if
	end if	
	if _cod_ramo = '018' then -- Si se reemplaza una pÃ³liza de salud
		call sp_sis124(a_no_poliza,_no_documento) returning _error, _error_desc;

		if _error <> 0 then
			return _error;
		end if
	end if
else
 	let _no_documento = _no_doc_orig;
   	select count(*)
	  into _canti
	  from emipomae
	 where actualizado = 1
	   and no_documento = _no_documento
	   and nueva_renov  = 'R'
	   and _vig_i >= vigencia_inic
	   and _vig_i < vigencia_final;

	if _canti > 0 and a_no_poliza not in('1632982') then
		return 1;
	end if
	let _no_poliza_ren = null;
	foreach
		select no_poliza
		  into _no_poliza_ren
	      from	emipomae
	     where no_documento = _no_documento
	       and actualizado  = 1
	       and no_poliza    <> a_no_poliza
		   and renovada     = 0
	  order by vigencia_final desc
	  
  		update emipomae
		   set renovada    = 1,
		       fecha_renov = current
		 where no_poliza   = _no_poliza_ren;
		--exit foreach;
	end foreach
	if _no_poliza_ren is not null then
		{update emipomae
		   set renovada    = 1,
		       fecha_renov = current
		 where no_poliza   = _no_poliza_ren;}

		update emipoliza			--inicializa el contador de rechazo.
		   set cant_rechazo = 0
		 where no_documento = _no_documento;
	end if
end if                                                                         
select sum(prima),sum(suma_asegurada)
  into _prima_emif, _suma_emif
  from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = '00000';

if _prima_neta <> 0 And _prima_emif = 0 then
	return 4;
end if
if _suma_asegurada <> 0 And _suma_emif = 0 then
	return 4;
end if
foreach
	select no_unidad,
		   sum(porc_partic_prima),
		   sum(porc_partic_suma)
	  into _no_unidad,
		   _prima_sus_cal,
		   _prima_sus_sum
	  from emifacon
	 where no_poliza     = a_no_poliza
	   and no_endoso     = '00000'
	 group by no_unidad, cod_cober_reas
  
	if _prima_sus_cal <> 100 then
		return 4;
	end if
	if _prima_sus_sum <> 100 then
		return 4;
	end if
end foreach

--VerificaciÃ³n de la serie de la vigencia de la pÃ³liza vs la serie de los contratos en la dist de reaseguro --24/04/2017
let _cnt_serie = 0;

select count(*)
  into _cnt_serie
  from emifacon r, reacomae c
 where r.cod_contrato = c.cod_contrato
   and no_poliza = a_no_poliza
   and c.serie <> _serie;

if _cnt_serie is null then
	let _cnt_serie = 0;
end if

if _cnt_serie <> 0 then 
	return 319; --Codigo en referencia a la tabla inserror.
end if

foreach
	select no_unidad,
		   cod_cober_reas
	  into _no_unidad,
		   _cod_cober_reas
	  from emipocob e, prdcober c
	 where e.cod_cobertura = c.cod_cobertura
	   and no_poliza = a_no_poliza
	 group by 1,2
     order by 1
	 
	select count(*)
	  into _cnt_reas
	  from emifacon
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = '00000'
	   and cod_cober_reas = _cod_cober_reas;

	if _cnt_reas is null then
		let _cnt_reas = 0;
	end if

	if _cnt_reas = 0 then
		return 320;
	end if
end foreach

if _no_fac_orig is null or _no_fac_orig = 'RENOVADA' then                                              
 	let _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
else                                                                      
 	let _no_factura = _no_fac_orig;                                        
end if 
-----------------------------------------------------------------------------------------                                                                   
-- VerificaciÃ³n del numero de factura que no este repetido. Federico Coronado 19/3/2019
select count(*) 
  into _canti 
  from emipomae 
 where actualizado = 1 
   and no_factura = _no_factura;

if _canti > 0 then
	return 1;
end if
-----------------------------------------------------------------------------------------
if _cod_ramo = '020' then	 --Renovaciones SODA, siempre debe ser inmediata
	update emipomae
	   set cod_perpago = '006',
	       no_pagos    = 1
	 where no_poliza = a_no_poliza;
end if
--------------------------------
select count(*)
  into _cant_fact
  from emipouni
 where no_poliza = a_no_poliza;

if _cant_fact = 0 then	--no tiene unidades, no se debe actualizar
	return 1;
end if
let _cant_fact = sp_sis503(a_no_poliza);
let _fronting  = sp_sis135(a_no_poliza);

if _fronting = 1 then --es fronting
	let _cod_formapag = "085";
end if

let _monto_visa = 0.00;

if _cod_formapag in ('003','005','092') then
	let _flag_electronico = 0;
	let _desc_electr = 5;

	if _prima_bruta <= 300 then
		let _flag_electronico = 1;
	end if

	if _cod_ramo in('004','008','016','019','018','023') then  --Inc. no aplica, Ramos Personales y SODA no aplican.
		let _flag_electronico = 1;
	end if
	
	if (_cod_ramo in ('001') and _cod_subramo = '006') or (_cod_ramo = '003' and _cod_subramo = '005') then
		let _flag_electronico = 1;
	end if
	
	if _cod_ramo = '009' and _declarativa = 1 then --Excluye PÃ³lizas Declarativa de Transporte
		let _flag_electronico = 1;
	end if
	
	let _cnt_emifafac = sp_sis439(a_no_poliza);

	if _cnt_emifafac = 1 then
		let _flag_electronico = 1;
	end if
	
	if _fronting = 1 then
		let _flag_electronico = 1;
	end if

	if _cod_perpago = '006' and _no_pagos = 1 then --pago inmediato no aplica pronto pago
		let _flag_electronico = 1;
	end if

	if _tipo_produccion in (3) then
		let _flag_electronico = 1;
	end if

	if _cod_grupo in ('00967','01024','21212') then
		let _desc_electr = 7;
	end if

	if _flag_electronico = 0 then 
		LET _monto_visa = (_prima_bruta - (_prima_bruta * _desc_electr /100)) / _no_pagos;		--cambio AMM
	else
		LET _monto_visa = _prima_bruta / _no_pagos;
	end if
	
	{if _cod_ramo not in('004','008','016','019','018','023') then  --Inc. no aplica, Ramos Personales y SODA no aplican.
		if (_cod_ramo in ('001') and _cod_subramo = '006')) or (_cod_ramo = '003' and _cod_subramo = '005') then
			LET _monto_visa = _prima_bruta / _no_pagos;
		else
			let _cnt_emifafac = sp_sis439(a_no_poliza);

			if _cnt_emifafac = 0 then
				LET _monto_visa = (_prima_bruta - (_prima_bruta * 5 /100)) / _no_pagos;		--cambio AMM
			end if
		end if
	else
		LET _monto_visa = _prima_bruta / _no_pagos;
	end if}
end if

IF _tipo_forma = 2 OR  _tipo_forma = 4 THEN -- Tarjetas de Credito/Ach
	LET _gestion = 'A';
ELSE
	LET _gestion = 'P';
END IF

IF _cod_origen IS NULL THEN
	LET _cod_origen = "001";
END IF

-- Nuevas validaciones a la forma de pago solicitas por
-- Carlos Berrocal el 30 - Sep - 2010

if _cod_tipoprod = "002" then -- Coaseguro Minoritario

	let _cod_formapag = "084";

elif _cod_tipoprod = "002" then -- Reaseguro Asumido

	let _cod_formapag = "070";

end if

if _tipo_forma in (2,4) then	--2=visa,4=ach
else
	if _ramo_sis = 3 then --Fianzas
		if _fronting = 1 then
			let _cod_formapag = "085";
		else
			let _cod_formapag = "089";
		end if
	end if
end if

update emipomae
   set no_documento      = _no_documento,
       no_factura        = _no_factura,
	   actualizado       = 1,
	   posteado          = '1',
	   fecha_suscripcion = today,
	   fecha_impresion   = today,
	   saldo             = prima_bruta,
	   monto_visa        = _monto_visa,
	   gestion			 = _gestion,
	   cod_origen		 = _cod_origen,
	   cobra_poliza		 = _cobra_poliza,
	   ind_fecha_emi	 = current,
	   cod_formapag      = _cod_formapag,
	   serie             = _serie,
	   fecha_primer_pago = _fecha_1_pago,
	   no_pagos			 = _no_pagos
 where no_poliza         = a_no_poliza;

-- Actualizando el no_documento de la poliza del producto -- Flotas

if a_no_poliza not in ('1166607','1215556','1656297')  then  --solicitud Kcruz '1656297' 01/10/2021
UPDATE prdpolpd
   SET no_documento = _no_documento
 WHERE no_documento = a_no_poliza;
end if 

-- Forma de pago por unidad
if _saldo_x_unidad = 1 then

	CALL sp_sis104(a_no_poliza) returning _error, _error_desc;  

	if _error <> 0 then
		return _error;
	end if

else

	-- Verificacion para Tarjetas de Credito y Ach

	IF _tipo_forma = 2 THEN -- Tarjetas de Credito

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobtahab
		 WHERE no_tarjeta = _no_tarjeta;
		
		IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Tarjetas

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_pagador;

			INSERT INTO cobtahab(
			no_tarjeta,
			cod_banco,
			nombre,
			fecha_exp,
			user_added,
			date_added,
			tipo_tarjeta
			)
			VALUES(
			_no_tarjeta,
			_cod_banco,
			_nombre_pagad,
			_fecha_exp,
			_user_added,
			TODAY,
			_tipo_tarjeta
			);

		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobtacre
		 WHERE no_tarjeta   = _no_tarjeta
		   AND no_documento = _no_documento;

		IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la Tarjeta
			
			IF _dia_cobros1 > 15 THEN
				LET _periodo_visa = 2;
			ELSE
				LET _periodo_visa = 1;
			END IF

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_contratante;

			INSERT INTO cobtacre(
			no_tarjeta,
			no_documento,
			cod_perpago,
			nombre,
			periodo,
			monto,
			fecha_ult_tran,
			procesar,
			excepcion,
			cargo_especial,
			dia
			)
			VALUES(
			_no_tarjeta,
			_no_documento,
			_cod_perpago,
			_nombre_pagad,
			_periodo_visa,
			_monto_visa,
			_fecha_1_pago,
			0,
			0,
			0.00,
			_dia_cobros1
			);
		END IF
		
		--Actualizar Letras a PÃ³lizas con Vigencias Anteriores a la fecha de hoy	02/09/2014		
		if _nueva_renov = 'R' and _vig_i < today then	   	
			UPDATE cobtacre
			   SET monto = _monto_visa
			 WHERE no_tarjeta	= _no_tarjeta
			   AND no_documento	= _no_documento;
		end if
	END IF

	IF _tipo_forma = 4 THEN -- Ach

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobcuhab
		 WHERE no_cuenta = _no_cuenta;
		 
		IF _nombre_pagad IS NULL THEN -- Crear el Maestro de Cuentas

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_pagador;

			INSERT INTO cobcuhab(
			no_cuenta,
			cod_banco,
			nombre,
			user_added,
			date_added,
			tipo_cuenta,
			tipo_transaccion,
			cod_pagador,
			monto_ach
			)
			VALUES(
			_no_cuenta,
			_cod_banco,
			_nombre_pagad,
			_user_added,
			TODAY,
			_tipo_cuenta,
			'D',
			_cod_pagador,
			_monto_visa
			);
		ELSE	--sumarle al monto del ach, el monto de la nueva poliza que se incorpora a la misma cuenta.
			
			IF _nueva_renov = 'N' THEN
				UPDATE cobcuhab
				   SET monto_ach = monto_ach + _monto_visa
				 WHERE no_cuenta = _no_cuenta;

				IF _dia_cobros1 > 15 THEN
					LET _periodo_visa = 2;
				ELSE
					LET _periodo_visa = 1;
				END IF

				SELECT nombre
				  INTO _nombre_pagad
				  FROM cliclien
				 WHERE cod_cliente = _cod_contratante;

				DELETE FROM cobcutas 
				 WHERE no_cuenta    = _no_cuenta
				   and no_documento = _no_documento;

				INSERT INTO cobcutas(
				no_cuenta,
				no_documento,
				cod_per_pago,
				nombre,
				periodo,
				monto,
				fecha_ult_tran,
				procesar,
				excepcion,
				cargo_especial,
				dia
				)
				VALUES(
				_no_cuenta,
				_no_documento,
				_cod_perpago,
				_nombre_pagad,
				_periodo_visa,
				_monto_visa,
				_fecha_1_pago,
				0,
				0,
				0.00,
				_dia_cobros1
				);
			ELSE
				if _vig_i < today then --Actualizar Letras a PÃ³lizas con Vigencias Anteriores a la fecha de hoy	02/09/2014		
					UPDATE cobcutas
					   SET monto        = _monto_visa
					 WHERE no_cuenta    = _no_cuenta
					   and no_documento = _no_documento;
				end if
			END IF
		END IF

		SELECT nombre
		  INTO _nombre_pagad
		  FROM cobcutas
		 WHERE no_cuenta    = _no_cuenta
		   AND no_documento = _no_documento;

		IF _nombre_pagad IS NULL THEN -- Crear el Detalle de la cuenta
			
			IF _dia_cobros1 > 15 THEN
				LET _periodo_visa = 2;
			ELSE
				LET _periodo_visa = 1;
			END IF

			SELECT nombre
			  INTO _nombre_pagad
			  FROM cliclien
			 WHERE cod_cliente = _cod_contratante;

			INSERT INTO cobcutas(
			no_cuenta,
			no_documento,
			cod_per_pago,
			nombre,
			periodo,
			monto,
			fecha_ult_tran,
			procesar,
			excepcion,
			cargo_especial,
			dia
			)
			VALUES(
			_no_cuenta,
			_no_documento,
			_cod_perpago,
			_nombre_pagad,
			_periodo_visa,
			_monto_visa,
			_fecha_1_pago,
			0,
			0,
			0.00,
			_dia_cobros1
			);
		END IF

	END IF
end if
-- Eliminar Registros

DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotrd WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcoama WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Tablas no Tienen Instrucciones Insert
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedhis WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

-- Endoso(0)

SELECT COUNT(*)
  INTO _cant_fact
  FROM endedmae
 WHERE no_factura  = _no_factura
   AND actualizado = 1;

IF _cant_fact IS NULL THEN
	LET _cant_fact = 0;
END IF

IF _cant_fact >= 1 THEN --'Numero de Factura Duplicado'
	RETURN 2;
END IF

LET _cant_fact = 0;

SELECT periodo
  INTO _periodo
  FROM emipomae
 WHERE no_poliza = a_no_poliza;	

let _no_endoso_ext   = sp_sis30(a_no_poliza, _no_endoso);
let _fecha_indicador = sp_sis156(today, _periodo);

INSERT INTO endedmae(
no_poliza,
no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
cod_tipocan,
cod_perpago,
cod_endomov,
no_documento,
vigencia_inic,
vigencia_final,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
prima_suscrita,
prima_retenida,
tiene_impuesto,
fecha_emision,
fecha_impresion,
fecha_primer_pago,
no_pagos,
actualizado,
no_factura,
fact_reversar,
date_added,
date_changed,
interna,
periodo,
user_added,
factor_vigencia,
suma_asegurada,
posteado,
activa,
vigencia_inic_pol,
vigencia_final_pol,
no_endoso_ext,
cod_tipoprod,
gastos,
fecha_indicador
)
SELECT
a_no_poliza,
_no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
_null,
cod_perpago,
_cod_endomov,
_no_documento,
vigencia_inic,
vigencia_final,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
prima_suscrita,
prima_retenida,
tiene_impuesto,
fecha_suscripcion,
fecha_impresion,
fecha_primer_pago,
no_pagos,
actualizado,
no_factura,
_null,
date_added,
date_changed,
0,
periodo,
user_added,
factor_vigencia,
suma_asegurada,
posteado,
1,
vigencia_inic,
vigencia_final,
_no_endoso_ext,
cod_tipoprod,
gastos,
_fecha_indicador
FROM emipomae
WHERE no_poliza = a_no_poliza;

SELECT COUNT(*)					--saber si inserto el endoso cero
  INTO _cantidad
  FROM endedmae
 WHERE no_poliza = a_no_poliza;

 if _cantidad is null then
	let _cantidad = 0;
 end if
 if _cantidad = 0 then
	return 1;
 end if
-- Descuentos
INSERT INTO endeddes(
no_poliza,
no_endoso,
cod_descuen,
porc_descuento
)
SELECT 
a_no_poliza,
_no_endoso,
cod_descuen,
porc_descuento
FROM emipolde
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endedrec(
no_poliza,
no_endoso,
cod_recargo,
porc_recargo
)
SELECT 
a_no_poliza,
_no_endoso,
cod_recargo,
porc_recargo
FROM emiporec
WHERE no_poliza = a_no_poliza;

-- Impuestos

INSERT INTO endedimp(
no_poliza,
no_endoso,
cod_impuesto,
monto
)
SELECT 
a_no_poliza,
_no_endoso,
cod_impuesto,
monto
FROM emipolim
WHERE no_poliza = a_no_poliza;

-- Unidades

INSERT INTO endeduni(
no_poliza,
no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_cliente,
suma_asegurada,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
reasegurada,
vigencia_inic,
vigencia_final,
beneficio_max,
desc_unidad,
prima_suscrita,
prima_retenida,
suma_aseg_adic,
tipo_incendio,
gastos,
cod_formapag,
cod_perpago,
no_pagos,
fecha_primer_pago,
tipo_tarjeta,
no_tarjeta,
fecha_exp,
cod_banco,
cobra_poliza,
no_cuenta,
tipo_cuenta,
cod_pagador,
cod_manzana,
cod_ramo
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_asegurado,
suma_asegurada,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
reasegurada,
vigencia_inic,
vigencia_final,
beneficio_max,
desc_unidad,
prima_suscrita,
prima_retenida,
suma_aseg_adic,
tipo_incendio,
gastos,
cod_formapag,
cod_perpago,
no_pagos,
fecha_primer_pago,
tipo_tarjeta,
no_tarjeta,
fecha_exp,
cod_banco,
cobra_poliza,
no_cuenta,
tipo_cuenta,
cod_pagador,
cod_manzana,
cod_ramo
FROM emipouni
WHERE no_poliza = a_no_poliza;

-- Descuentos

INSERT INTO endunide(
no_poliza,
no_endoso,
no_unidad,
cod_descuen,
porc_descuento
)
SELECT 
a_no_poliza,
_no_endoso,
no_unidad,
cod_descuen,
porc_descuento
FROM emiunide
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endunire(
no_poliza,
no_endoso,
no_unidad,
cod_recargo,
porc_recargo
)
SELECT 
a_no_poliza,
_no_endoso,
no_unidad,
cod_recargo,
porc_recargo
FROM emiunire
WHERE no_poliza = a_no_poliza;

-- Descripcion

INSERT INTO endedde2(
no_poliza,
no_endoso,
no_unidad,
descripcion
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
descripcion
FROM emipode2
WHERE no_poliza = a_no_poliza;

-- Acreedores

INSERT INTO endedacr(
no_poliza,
no_endoso,
no_unidad,
cod_acreedor,
limite
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_acreedor,
limite
FROM emipoacr
WHERE no_poliza = a_no_poliza;

-- Autos

INSERT INTO endmoaut(
no_poliza,
no_endoso,
no_unidad,
no_motor,
cod_tipoveh,
uso_auto,
no_chasis,
ano_tarifa
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
no_motor,
cod_tipoveh,
uso_auto,
_null,
ano_tarifa
FROM emiauto
WHERE no_poliza = a_no_poliza;

-- Transporte

INSERT INTO endmotra(
no_poliza,
no_endoso,
no_unidad,
cod_nave,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello,
fecha_viaje,
viaje_desde,
viaje_hasta,
sobre
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_nave,
consignado,
tipo_embarque,
clausulas,
contenedor,
sello,
fecha_viaje,
viaje_desde,
viaje_hasta,
sobre
FROM emitrans
WHERE no_poliza = a_no_poliza;

INSERT INTO endmotrd(
no_poliza,
no_endoso,
no_unidad,
especiales
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
especiales
FROM emitrand
WHERE no_poliza = a_no_poliza;

-- Cumulos de Incendio

INSERT INTO endcuend(
no_poliza,
no_endoso,
no_unidad,
cod_ubica,
suma_incendio,
suma_terremoto,
prima_incendio,
prima_terremoto
)
SELECT
a_no_poliza,
_no_endoso,
no_unidad,
cod_ubica,
suma_incendio,
suma_terremoto,
prima_incendio,
prima_terremoto
FROM emicupol
WHERE no_poliza = a_no_poliza;

-- Coberturas

INSERT INTO endedcob(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
orden,
tarifa,
deducible,
limite_1,
limite_2,
prima_anual,
prima,
descuento,
recargo,
prima_neta,
date_added,
date_changed,
desc_limite1,
desc_limite2,
factor_vigencia,
opcion
)
SELECT
no_poliza,
_no_endoso,
no_unidad,
cod_cobertura,
orden,
tarifa,
deducible,
limite_1,
limite_2,
prima_anual,
prima,
descuento,
recargo,
prima_neta,
date_added,
date_changed,
desc_limite1,
desc_limite2,
factor_vigencia,
0
FROM emipocob
WHERE no_poliza = a_no_poliza;

-- Descuentos

INSERT INTO endcobde(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
cod_descuen,
porc_descuento
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_cobertura,
cod_descuen,
porc_descuento
FROM emicobde
WHERE no_poliza = a_no_poliza;

-- Recargos

INSERT INTO endcobre(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
cod_recargo,
porc_recargo
)
SELECT 
no_poliza,
_no_endoso,
no_unidad,
cod_cobertura,
cod_recargo,
porc_recargo
FROM emicobre
WHERE no_poliza = a_no_poliza;

BEGIN

DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _no_cambio      SMALLINT;
DEFINE _no_endoso      CHAR(5);
DEFINE _no_unidad      CHAR(5);
DEFINE _cod_cober_reas CHAR(3);
DEFINE _no_cambio_coas CHAR(3);
DEFINE _cantidad       SMALLINT;

LET _no_cambio      = 0;
LET _no_endoso      = '00000';
LET _no_cambio_coas = '000';

DELETE FROM emireagf WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagc WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireagm WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

DELETE FROM emireafa WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireaco WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emireama WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

SELECT vigencia_inic,
       vigencia_final
  INTO _vigencia_inic,
       _vigencia_final
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

-- Actualizacion de las Vigencias en las Unidades

UPDATE emipouni
   SET vigencia_inic  = _vigencia_inic,
       vigencia_final = _vigencia_final,
	   fecha_emision  = TODAY,
	   prima_bruta    = prima_bruta + gastos
 WHERE no_poliza      = a_no_poliza;

UPDATE emidepen
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE emipreas
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE emiprede
   SET date_added     = TODAY,
	   user_added     = _user_added
 WHERE no_poliza      = a_no_poliza;

UPDATE endeduni
   SET vigencia_inic  = _vigencia_inic,
       vigencia_final = _vigencia_final,
	   prima_bruta    = prima_bruta + gastos
 WHERE no_poliza      = a_no_poliza
   AND no_endoso      = _no_endoso;

select count(*)
  into _cantidad_uni
  from emipouni
 where no_poliza = a_no_poliza;

if _cantidad_uni > 1 then

	update emipomae
	   set colectiva = "C"
     where no_poliza = a_no_poliza;

end if

-- Historico de Reaseguro Global

update emifafac
   set monto_comision = prima * porc_comis_fac / 100,
       monto_impuesto = prima * porc_impuesto  / 100
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso
   and prima          <> 0.00;

INSERT INTO emireagm(
no_poliza,
no_cambio,
vigencia_inic,
vigencia_final
)
VALUES( 
a_no_poliza,
_no_cambio,
_vigencia_inic,
_vigencia_final
);

INSERT INTO emireagc(
no_poliza,
no_cambio,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
)
SELECT 
a_no_poliza, 
_no_cambio,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emigloco
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

INSERT INTO emireagf(
no_poliza,
no_cambio,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
)
SELECT 
a_no_poliza, 
_no_cambio,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
FROM emiglofa
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

FOREACH
 SELECT	no_unidad,
        cod_cober_reas
   INTO	_no_unidad,
        _cod_cober_reas
   FROM	emifacon
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = _no_endoso
  GROUP BY no_unidad, cod_cober_reas

	INSERT INTO emireama(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	vigencia_inic,
	vigencia_final
	)
	VALUES(
	a_no_poliza, 
	_no_unidad,
	_no_cambio,
	_cod_cober_reas,
	_vigencia_inic,
	_vigencia_final
	);

END FOREACH

INSERT INTO emireaco(
no_poliza,
no_unidad,
no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
)
SELECT 
a_no_poliza, 
no_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emifacon
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

INSERT INTO emireafa(
no_poliza,
no_unidad,
no_cambio,
cod_cober_reas,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
)
SELECT 
a_no_poliza, 
no_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
cod_coasegur,
porc_partic_reas,
porc_comis_fac,
porc_impuesto
FROM emifafac
WHERE no_poliza = a_no_poliza
  AND no_endoso = _no_endoso;

-- Coaseguros 

DELETE FROM emihcmm WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;
DELETE FROM emihcmd WHERE no_poliza = a_no_poliza AND no_cambio = _no_cambio;

INSERT INTO emihcmm(
no_poliza,
no_cambio,
vigencia_inic,
vigencia_final,
fecha_mov,
no_endoso
)
VALUES( 
a_no_poliza,
_no_cambio_coas,
_vigencia_inic,
_vigencia_final,
TODAY,
_no_endoso
);

INSERT INTO emihcmd(
no_poliza,
no_cambio,
cod_coasegur,
porc_partic_coas,
porc_gastos
)
SELECT 
a_no_poliza,
_no_cambio_coas,
cod_coasegur,
porc_partic_coas,
porc_gastos
FROM emicoama
WHERE no_poliza = a_no_poliza;

SELECT COUNT(*)
  INTO _cantidad
  FROM emihcmd
 WHERE no_poliza = a_no_poliza;

-- Verifica si el tipo de produccion "Coaseg. Mayoritario" no ha sido cambiado. *Amado*

SELECT tipo_produccion
  INTO _tipo_produccion
  FROM emitipro
 WHERE cod_tipoprod = _cod_tipoprod;

IF _cantidad IS NULL THEN
	LET _cantidad = 0;
END IF
									 
IF _cantidad = 0 THEN

	DELETE FROM emihcmm
     WHERE no_poliza = a_no_poliza;

END IF

IF _tipo_produccion <> 2 THEN

	DELETE FROM emihcmd
     WHERE no_poliza = a_no_poliza;

	DELETE FROM emihcmm
     WHERE no_poliza = a_no_poliza;

	DELETE FROM emicoama
     WHERE no_poliza = a_no_poliza;

END IF

-- Guarda el Historico de Coaseguro

select prima_neta,
       suma_asegurada,
	   cod_formapag
  into _prima_neta,
       _suma_asegurada,
	   _cod_formapag
  from emipomae
 where no_poliza = a_no_poliza;

INSERT INTO endcoama(
	   no_poliza,
	   no_endoso,
	   cod_coasegur,
	   porc_partic_coas,
	   porc_gastos,
	   prima,
	   suma
	   )
SELECT no_poliza,
       _no_endoso,
       cod_coasegur,
       porc_partic_coas,
       porc_gastos,
	   (_prima_neta      * porc_partic_coas / 100),
	   (_suma_asegurada  * porc_partic_coas / 100)
  FROM emicoama
 WHERE no_poliza = a_no_poliza;

CALL sp_pro100(a_no_poliza, _no_endoso); -- Historico de endedmae (endedhis)
CALL sp_sis70(a_no_poliza, _no_endoso);	 -- Historico de emipoagt (endmoage)

---
-- Campos Subir_BO para el DWH

CALL sp_sis94(a_no_poliza, _no_endoso) returning _error, _error_desc;  

if _error <> 0 then
	return _error;
end if

-- Registros para el Comprobante de Reaseguro

call sp_rea008(1, a_no_poliza, _no_endoso) returning _error, _error_desc;

if _error <> 0 then
	return _error;
end if 

-- Registros Para la Numeracion de las Polizas (Archivo en Logistica)
call sp_log002(a_no_poliza, _no_endoso) returning _error, _error_desc;

if _error <> 0 then
	return _error;
end if 

-- cargar la tabla emiletra
call sp_pro525(a_no_poliza) returning _error, _error_desc;

if _error <> 0 then
	return _error;
end if

----creacion del endoso de 5% de descuento electronico
let _monto_desc = 0;

if _cod_formapag in('003','005','092') then	
	if _flag_electronico = 0 then 
		let _monto_desc = _prima_bruta * _desc_electr / 100;
		call sp_pro862b(a_no_poliza, _user_added, _monto_desc) returning _error, _error_desc; -- creacion del endoso de pronto pago
	end if
end if
{if _cod_formapag in('003','005') and _cod_ramo not in('001','004','008','016','019','018','020') then	--si es forma de pago ach/tcr, hacer endoso de pronto pago
	if _cod_ramo = '003' and _cod_subramo = '005' then
	else

		let _cnt_emifafac = 0;

		select count(*)
		  into _cnt_emifafac
		  from emifafac
		 where no_poliza = a_no_poliza;

		if _cnt_emifafac is null then
			let _cnt_emifafac = 0;
		end if

		if _cnt_emifafac = 0 then	--No aplica facultativos
			let _monto_desc = _prima_bruta * 5 / 100;
			call sp_pro862b(a_no_poliza, _user_added, _monto_desc) returning _error, _error_desc; -- creacion del endoso de pronto pago
		end if
	end if
end if	}
--let _error = sp_pro326(a_no_poliza,_user_added);	 --Insertar en el pool de impresion Armando, no habilitar todavia.

CALL sp_pro867(a_no_poliza,_nueva_renov) returning _error, _error_desc; --Insertar en parmailsend para la carta de bienvenida - pol. Nvas y Ren.
if _error <> 0 then
	return _error;
end if

let _error = sp_sis416(a_no_poliza);	--Marcar con la nueva tarifa a la unidad 28/07/2014

CALL sp_pro371h(a_no_poliza) returning _error, _error_desc; --Insertar en emirenduc las polizas del grupo Ducruet Banisi -- Amado Perez - 08-03-2021
if _error <> 0 then
	return _error;
end if
END
RETURN 0;
END
END PROCEDURE 
                                                                                 
