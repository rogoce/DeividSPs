--  Procedimiento para determinar si una poliza electronico aplica o no para el descuento de 5% 
-- Creado: 14/12/2011 - Autor: Armando Moreno M.

drop procedure sp_sis395;
create procedure sp_sis395(a_no_documento char(20))
returning	smallint,
			char(50),
			decimal(16,2);

define _nombre_asegurado	varchar(100);
define _nombre_producto		varchar(50);
define _nombre_agente		varchar(50);
define _error_desc			varchar(50);
define _no_documento		char(20);
define _cod_asegurado		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_perpago			char(3);
define _chequera2			char(3);
define _cod_ramo			char(3);
define _chequera			char(3);
define _tipo_mov			char(1);
define _prima_nueva			dec(16,2);
define _prima_bruta			dec(16,2);
define _porc_rech			dec(16,2);
define _ult_pago			dec(16,2);
define _pagado				dec(16,2);
define _letra				dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _valor				dec(16,2);
define _tipo_produccion		smallint;
define _declarativa			smallint;
define v_existe_end			smallint;
define _existe_rev			smallint;
define _cant_rech			smallint;
define _pagos_tot			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _manzana				smallint;
define _result				smallint;
define _pagos				smallint;
define _cant				smallint;
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

let _no_pagos  = 0;
let _cant      = 0;
let _cant_rech = 0;
let _prima_bruta = 0;
let _monto       = 0;
let _valor       = 0;

--set debug file to "sp_sis395.trc";
--trace on;

let _ult_pago = 0;
return 1,'SE DESACTIVA',_ult_pago;  --lo quite el 16/07/2015 9:57 am

let _fecha_hoy = today;

foreach
	select no_poliza,
		   vigencia_inic
	  into _no_poliza,
		   _vigencia_inic
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_final desc

	if _vigencia_inic <= _fecha_hoy then
		exit foreach;
	end if
end foreach

select vigencia_inic,
       fecha_suscripcion,
       cod_ramo,
	   cod_formapag,
	   no_pagos,
	   cod_subramo,
	   prima_bruta,
	   declarativa,
	   cod_tipoprod,
	   cod_perpago,
	   fronting
  into _vigencia_inic,
  	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _no_pagos,
	   _cod_subramo,
	   _prima_bruta,
	   _declarativa,
	   _cod_tipoprod,
	   _cod_perpago,
	   _fronting
  from emipomae
 where no_poliza = _no_poliza;

if _vigencia_inic is null then
else
   let _fecha_suscripcion = mdy(month(_vigencia_inic),'01',year(_vigencia_inic));  --puesto en prod. armando 16/08/2013	 -- corregido amado 26/11/2013 caso 16140 de migdalia sanchez 
end if

if _cod_formapag not in('003','005') then	--Solo aplica tarjeta de credito y ach
	return 1,'SOLO APLICA TARJETA DE CREDITO Y ACH',0;
else
    if _cod_formapag = '003' then --tarjeta
		let _chequera = '029';	 
		let _chequera2 = '031';
	else
		let _chequera = '030';
		let _chequera2 = '030';
	end if
end if

--Pólizas con primas menores de bl. 300 no aplican
if _prima_bruta <= 300 then
	let _error_desc = 'Esta póliza no aplica para este descuento. La prima es menor de b/.300.00.';
	return 1,_error_desc,0.00;
end if

if _cod_ramo in('004','008','016','018','019','023') then  --Inc. no aplica, Ramos Personales y SODA no aplican.
	return 1,'RAMO NO APLICA',0;
end if

if _cod_ramo = '009' and _declarativa = 1 then
	let _error_desc = 'No Aplica. La Póliza es Declarativa de Transporte.';
	return 1,_error_desc,0.00;
end if

if (_cod_ramo = '003' and _cod_subramo = '005') or  (_cod_ramo in ('001') and _cod_subramo = '006') then
	let _error_desc = 'No Aplica. La Pólizas de Zona Libre/France Field no participan del descuento...';
	return 1,_error_desc,0.00;
end if

--Verifica si la manzana es Zona Libre
call sp_pro857(_no_poliza) returning _manzana;
if _manzana = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Unidad(es) con ubicación en Zona Libre.';
	return 1,_error_desc,0;
end if

if _fronting = 1 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Fronting.";
	return 1,_error_desc,0;
end if

if _cod_perpago = '006' and _no_pagos = 1 then --pago inmediato no aplica pronto pago
	let _error_desc = "Póliza con pago INMEDIATO, NO APLICA.";
	return 1,_error_desc,0;
end if

--Excepcion de Coaseguros
select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion in (3) then
	return 1,"La Póliza no cumple con las condiciones. La Póliza es Coaseguro.",0;
end if


--Excepcion Facultativos
let _cant = 0;
let _cant = sp_sis439(_no_poliza);

if _cant = 1 then
	return 1,'FACULTATIVOS NO APLICAN',0;
end if

{
if _cod_ramo = '002' then
	select count(*)
	  into _cant
	  from emipocob
	 where no_poliza = _no_poliza;

	if _cant = 3 then
		select count(*)
		  into _cant
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in("00113","00107","00102","00117"); --Danos a la prop ajena,Gastos medicos,Lesiones corporales,Asist.Medica

		if _cant > 0 then
			return 1,'AUTO POLIZA RC NO APLICA',0;
		end if
	end if		
end if

if _cod_ramo = '023' then  --auto flotas

	foreach
	   select no_unidad
		 into _no_unidad
		 from emipouni
		where no_poliza = _no_poliza

		select count(*)
		  into _cant
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in("01304","01305","01302","01299"); --Danos a la prop ajena,Gastos medicos,Lesiones corporales,Asist.Medica

		if _cant > 3 then

			
		end if

	if _cant = 3 then
		select count(*)
		  into _cant
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in("00113","00107","00102","00117"); --Danos a la prop ajena,Gastos medicos,Lesiones corporales,Asist.Medica

		if _cant > 0 then
			return 1,'AUTO POLIZA RC NO APLICA',0;
		end if
	end if		
end if}

select cant_rechazo
  into _cant_rech
  from emipoliza
 where no_documento = a_no_documento;

let _porc_rech = (_cant_rech / _no_pagos) * 100;

if _porc_rech >= 50 then	--Tiene el 50% de rechazos
	return 1,'TIENE MAS DEL 50% DE RECHAZOS',0;
end if

let _pagos     = 0;
let _pagos_tot = 0;
let _result    = 0;

--Determinar cuantos pagos tiene electronicos
{	SELECT count(*)
  INTO _pagos
  FROM cobredet d, cobremae m
 WHERE d.actualizado  = 1
   AND d.cod_compania = '001'
   AND d.doc_remesa   = a_no_documento
   AND d.tipo_mov     IN ('P','N')
   AND d.no_remesa    = m.no_remesa
   AND m.tipo_remesa  IN ('A', 'M', 'C')
   AND d.fecha >= _fecha_suscripcion
   AND m.cod_chequera in(_chequera,_chequera2);}

let _pagos = 0;

foreach		--determinar cuantos pagos tiene electronicos
	select d.tipo_mov
	  into _tipo_mov
	  from cobredet d, cobremae m
	 where d.no_remesa = m.no_remesa
	   and d.doc_remesa = a_no_documento
	   and d.tipo_mov in ('P','N')
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and d.actualizado = 1
	   and d.cod_compania = '001'
	   and d.fecha >= _fecha_suscripcion
	   and m.cod_chequera in(_chequera,_chequera2)

	if _tipo_mov = 'P' then
		let _pagos = _pagos + 1;
	elif _tipo_mov = 'N' then
		let _pagos = _pagos - 1;
	end if
end foreach

--Determinar cuantos pagos tiene en total
{	SELECT count(*)
  INTO _pagos_tot
  FROM cobredet d, cobremae m
 WHERE d.actualizado  = 1
   AND d.cod_compania = '001'
   AND d.doc_remesa   = a_no_documento
   AND d.tipo_mov     IN ('P','N')
   AND d.no_remesa    = m.no_remesa
   AND m.tipo_remesa  IN ('A', 'M', 'C')
   AND d.fecha >= _fecha_suscripcion;}

select count(*)
  into v_existe_end
  from endedmae
 where no_poliza   = _no_poliza
   and cod_endomov = "024"
   and actualizado = 1;	     --endoso de descuento de pronto pago

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza   = _no_poliza
   and cod_endomov = '025'		 --endoso de reversion de descuento de pronto pago
   and actualizado = 1;

if (v_existe_end - _existe_rev) > 0 then
	return 1,'ENDOSO YA EXISTIA',0;
end if

let _pagos_tot = 0;
let _pagado    = 0;

foreach		--determinar lo pagado
	select d.tipo_mov,d.monto
	  into _tipo_mov,_monto
	  from cobredet d, cobremae m
	 where d.actualizado  = 1
	   and d.cod_compania = '001'
	   and d.doc_remesa   = a_no_documento
	   and d.tipo_mov     in ('P','N')
	   and d.no_remesa    = m.no_remesa
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and d.fecha >= _fecha_suscripcion

	if _tipo_mov = 'P' then
		let _pagos_tot = _pagos_tot + 1;
	elif _tipo_mov = 'N' then
		let _pagos_tot = _pagos_tot - 1;
	end if

	let _pagado = _pagado + _monto;
end foreach

--let _valor     = _pagado * _no_pagos;

--let _pagos_tot = round(_valor / _prima_bruta);


let _result = _pagos_tot - _pagos;

{if _result > 2 then
	return 1,'TIENE MAS DE DOS PAGOS POR FUERA'|| _result,0;
end if} --se puso en comentario por instrucción de Enilda 21/07/2015

if (_no_pagos - _pagos_tot) = 1 then  --viene el ultimo pago

	let _ult_pago = 0;
	let _letra = 0;
	let _saldo = 0;
	let _ult_pago = _prima_bruta * 0.05;
	let _letra = _prima_bruta / _no_pagos;
	let _saldo = _prima_bruta - _pagado;

	if _saldo < _letra then				 --Puesto en produccion 01/07/2013 Armando
		let _letra = _saldo;
	end if

	let _ult_pago = _letra - _ult_pago;

    if _ult_pago <= 0 then
		return 1,'VALOR NEGATIVO O CERO',0;
	end if

else
	return 1,'NO ES EL ULTIMO PAGO,TIENE '|| _pagos || ' DE ' || _no_pagos,0;
end if

return 0,'SI APLICA',_ult_pago;

end procedure;