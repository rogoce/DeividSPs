--  Procedimiento para determinar si una poliza electronico aplica o no para el descuento de 5% 

-- Creado: 14/12/2011 - Autor: Armando Moreno M.

drop procedure sp_sis403;
create procedure sp_sis403(a_no_documento char(20))
returning	smallint,
			char(50),
			decimal(16,2);


define _nombre_asegurado	varchar(100);
define _error_desc			varchar(100);
define _nombre_producto		varchar(50);
define _nombre_agente		varchar(50);
define _no_documento		char(20);
define _cod_asegurado		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_subramo			char(3);
define _chequera2			char(3);
define _chequera			char(3);
define _cod_ramo			char(3);
define _tipo_mov			char(1);
define _prima_bruta			dec(16,2);
define _prima_nueva			dec(16,2);
define _porc_rech			dec(16,2);
define _descuento			dec(16,2);
define _pagado				dec(16,2);
define _valor				dec(16,2);
define _tipo_produccion		smallint;
define v_existe_end			smallint;
define _declarativa			smallint;
define _existe_rev			smallint;
define _existe_end			smallint;
define _cant_rech			smallint;
define _pagos_tot			smallint;
define _no_pagos			smallint;
define _fronting			smallint;
define _manzana				smallint;
define _result				smallint;
define _pagos				smallint;
define _cant				smallint;
define _fecha_suscripcion   date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

let _no_pagos    = 0;
let _cant        = 0;
let _cant_rech   = 0;
let _prima_bruta = 0;
let _descuento   = 0;
let v_existe_end = 0;
let	_existe_rev  = 0;

--set debug file to "sp_sis403.trc";
--trace on;

--LET _no_poliza = sp_sis21(a_no_documento); 07/03/2013 se puso en comentario

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
	   cod_tipoprod,
	   fronting,
	   cod_perpago,
	   declarativa,
	   cod_grupo
  into _vigencia_inic,
	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _no_pagos,
	   _cod_subramo,
	   _prima_bruta,
	   _cod_tipoprod,
	   _fronting,
	   _cod_perpago,
	   _declarativa,
	   _cod_grupo
  from emipomae
 where no_poliza = _no_poliza;

if _cod_grupo in ('124','78020','125','148','1122','77960')   then --Banisi - Lizzy Bernal, Se adicona Feliz Abadia , Solicita AMORENO:17/09/2018  -- Banisi - Bac, Abadia, Ducruet 15/01/2019 CASO: 30140 USER: ASTANZIO   -- SD#3010 77960  11/04/2022 10:00  
	return 1,'El Grupo de la Póliza no Aplica para el descuento.',0.00;
end if   
   

if _cod_formapag not in('092') then	--Ducruet Electronico
	return 1,'SOLO APLICA DUCRUET ELECTRONICO',0;
end if

if _no_pagos > 11 then
	return 1,'SOLO PERIMITE 11 LETRAS MAXIMO',0;
end if
	
--Pólizas con primas menores de bl. 300 no aplican
if _prima_bruta <= 300 then

	return 1,'Esta póliza no aplica para este descuento. La prima es menor de b/.300.00.',0;
end if

if _cod_ramo in('004','016','019','018','023','008','001') then  --Ramos Personales, Fianzas y Flotas. incendio
	return 1,'RAMO NO APLICA',0;
end if

--Excepcion de Coaseguros
select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion in (3) then
	return 1,"La Póliza no cumple con las condiciones. La Póliza es Coaseguro.",0;
end if

if _vigencia_inic is null then
else
   let _fecha_suscripcion = _vigencia_inic;
end if

if _fronting = 1 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Fronting.";
	return 1,_error_desc,0;
end if

if _cod_perpago = '006' and _no_pagos = 1 then --pago inmediato no aplica pronto pago
	let _error_desc = "Póliza con pago INMEDIATO, NO APLICA.";
	return 1,_error_desc,0;
end if

if _cod_ramo = '009' and _declarativa = 1 then --Excluye Pólizas Declarativa de Transporte
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Declarativa de Transporte.";
	return 1,_error_desc,0;
end if

--Excepcion Facultativos
let _cant = 0;
let _cant = sp_sis439(_no_poliza);

if _cant = 1 then
	return 1,'FACULTATIVOS NO APLICAN',0;
end if

if (_cod_ramo in ('001') and _cod_subramo = '006') or (_cod_ramo in ('003') and _cod_subramo = '005') then
	let _error_desc = 'No Aplica. La Pólizas de Zona Libre/France Field no participan del descuento...';
	return 1,_error_desc,0;
end if

--Verifica si la manzana es Zona Libre
call sp_pro857(_no_poliza) returning _manzana;
if _manzana = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Unidad(es) con ubicación en Zona Libre.';
	return 1,_error_desc,0;
end if

let _pagos     = 0;
let _pagos_tot = 0;
let _result    = 0;

let _pagos_tot = 0;

foreach		--determinar cuantos pagos tiene en total
	select d.tipo_mov
	  into _tipo_mov
	  from cobredet d, cobremae m
	 where d.actualizado  = 1
	   and d.cod_compania = '001'
	   and d.doc_remesa   = a_no_documento
	   and d.tipo_mov     iN ('P','N')
	   AND d.no_remesa    = m.no_remesa
	   AND m.tipo_remesa  IN ('A', 'M', 'C')
	   AND d.fecha >= _fecha_suscripcion

	if _tipo_mov = 'P' then
		let _pagos_tot = _pagos_tot + 1;
	elif _tipo_mov = 'N' then
		let _pagos_tot = _pagos_tot - 1;
	end if
end foreach

let _descuento = (_prima_bruta * 0.05);

if (_no_pagos - _pagos_tot) = 1 then  --viene el ultimo pago
else
	select sum(d.monto)
	  into _pagado
	  from cobredet d, cobremae m
	 where d.actualizado  = 1
	   and d.cod_compania = '001'
	   and d.doc_remesa   = a_no_documento
	   and d.tipo_mov     in ('P','N')
	   and d.no_remesa    = m.no_remesa
	   and d.no_poliza    = _no_poliza
	   and m.tipo_remesa  in ('A', 'M', 'C');

	let _valor = _prima_bruta - _descuento;

	if abs(_pagado - _valor) > 0.03 then
		if _pagado < _valor then
			return 1, 'No ha Completado el Pago Aun.', _descuento;
		end if
	end if
end if

--Verifica si ya se le aplico descuento de pronto pago
select count(*)
  into _existe_end
  from endedmae
 where no_poliza	= _no_poliza
   and cod_endomov	= '024'
   and actualizado  = 1;

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza	= _no_poliza
   and cod_endomov	= '025'
   and actualizado  = 1;

if (_existe_end - _existe_rev) > 0 then
	return 2,'Esta póliza ya tiene el endoso de descuento aplicado, Por Favor Verifique...',_descuento;
end if

return 0,'SI APLICA',_descuento;

end procedure;