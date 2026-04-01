--  Procedimiento para determinar si una poliza electronico aplica o no para el descuento de 5% 

-- Creado: 14/12/2011 - Autor: Armando Moreno M.

--drop procedure sp_sis395bk;
create procedure sp_sis395bk(a_no_documento char(20))
returning smallint,char(50),decimal(16,2);


define _no_documento     char(20);
define _cod_formapag     char(3);
define _porc_rech        dec(16,2);
define _prima_nueva      dec(16,2);
define _vigencia_inic    date;
define _fecha_suscripcion   date;
define _cod_agente       char(5);
define _nombre_agente    varchar(50);
define _cod_asegurado    char(10);
define _nombre_asegurado varchar(100);
define _no_poliza        char(10);
define _nombre_producto  varchar(50);
define _cod_ramo         char(3);
define _cod_subramo      char(3);
define _no_pagos         smallint;
define _cant,_cant_rech	 smallint;
define _pagos            smallint;
define _chequera,_chequera2  char(3);
define v_existe_end      smallint;
define _existe_rev       smallint;
define _prima_bruta      dec(16,2);
define _ult_pago         dec(16,2);
define _letra            dec(16,2);
define _saldo            dec(16,2);
define _pagado           dec(16,2);
define _monto            dec(16,2);
define _pagos_tot,_result smallint;
define _fecha_hoy		 date;
define _tipo_mov         char(1);
define _valor            dec(16,2);

set isolation to dirty read;

let _no_pagos  = 0;
let _cant      = 0;
let _cant_rech = 0;
let _prima_bruta = 0;
let _monto       = 0;
let _valor       = 0;

--set debug file to "sp_sis395.trc";
--trace on;


let _fecha_hoy = '15/07/2013';

foreach
 select	no_poliza,
		vigencia_inic
   into	_no_poliza,
		_vigencia_inic
   from	emipomae
  where no_documento       = a_no_documento
	and actualizado        = 1
  order by vigencia_final desc
	if _vigencia_inic <= _fecha_hoy then
		exit foreach;
	end if
end foreach

SELECT vigencia_inic,
       fecha_suscripcion,
       cod_ramo,
	   cod_formapag,
	   no_pagos,
	   cod_subramo,
	   prima_bruta
  INTO _vigencia_inic,
  	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _no_pagos,
	   _cod_subramo,
	   _prima_bruta
  FROM emipomae
 WHERE no_poliza = _no_poliza;

if _vigencia_inic is null then
else
   let _fecha_suscripcion = _vigencia_inic;
end if

if _cod_ramo in('001','004','016','019','018','020') then  --Inc. no aplica, Ramos Personales y SODA no aplican.
	return 1,'RAMO NO APLICA',0;
end if

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


select count(*)
  into _cant
  from emifafac
 where no_poliza = _no_poliza;

if _cant > 0 then	--No aplica facultativos
	return 1,'FACULTATIVOS NO APLICAN',0;
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

let _pagos = 0;

FOREACH		--Determinar cuantos pagos tiene electronicos

SELECT d.tipo_mov
  INTO _tipo_mov
  FROM cobredet d, cobremae m
 WHERE d.actualizado  = 1
   AND d.cod_compania = '001'
   AND d.doc_remesa   = a_no_documento
   AND d.tipo_mov     IN ('P','N')
   AND d.no_remesa    = m.no_remesa
   AND m.tipo_remesa  IN ('A', 'M', 'C')
   AND d.fecha >= _fecha_suscripcion
   AND m.cod_chequera in(_chequera,_chequera2)

   if _tipo_mov = 'P' then
		let _pagos = _pagos + 1;
   elif _tipo_mov = 'N' then
		let _pagos = _pagos - 1;
   end if

END FOREACH

SELECT count(*)
  INTO v_existe_end
  FROM endedmae
 WHERE no_poliza   = _no_poliza
   AND cod_endomov = "024";	     --Endoso de Descuento de Pronto Pago

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza   = _no_poliza
   and cod_endomov = '025'		 --Endoso de Reversion de Descuento de Pronto Pago
   and actualizado = 1;

if (v_existe_end - _existe_rev) > 0 then
	return 1,'ENDOSO YA EXISTIA',0;
end if

let _pagos_tot = 0;
let _pagado    = 0;

FOREACH		--Determinar lo pagado

SELECT d.tipo_mov,d.monto
  INTO _tipo_mov,_monto
  FROM cobredet d, cobremae m
 WHERE d.actualizado  = 1
   AND d.cod_compania = '001'
   AND d.doc_remesa   = a_no_documento
   AND d.tipo_mov     IN ('P','N')
   AND d.no_remesa    = m.no_remesa
   AND m.tipo_remesa  IN ('A', 'M', 'C')
   AND d.fecha >= _fecha_suscripcion

   if _tipo_mov = 'P' then
		let _pagos_tot = _pagos_tot + 1;
   elif _tipo_mov = 'N' then
		let _pagos_tot = _pagos_tot - 1;
   end if

   let _pagado = _pagado + _monto;

END FOREACH

let _result = _pagos_tot - _pagos;

if _result > 2 then
	return 1,'TIENE MAS DE DOS PAGOS POR FUERA'|| _result,0;
end if

if (_no_pagos - _pagos_tot) = 1 then  --viene el ultimo pago

	let _ult_pago = 0;
	let _letra    = 0;
	let _saldo    = 0;
	let _ult_pago = _prima_bruta * 0.05;
	let _letra    = _prima_bruta / _no_pagos;

	let _saldo    = _prima_bruta - _pagado;
	if _saldo     < _letra then				 --Puesto en produccion 01/07/2013 Armando
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

end procedure