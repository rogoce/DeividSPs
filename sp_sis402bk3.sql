--  Procedimiento para determinar si una poliza aplica o no para el descuento de 5% 
-- Creado: 15/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_sis402('','')

--drop procedure sp_sis402bk3;
create procedure sp_sis402bk3(
a_no_poliza		char(10),
a_fecha_hoy		date,
a_monto_pago	decimal(16,2)	default 0,
a_no_remesa		char(10)		default '00000')
returning	smallint,
			varchar(120),
			decimal(16,2);

define _error_desc			varchar(120);
define _nom_ramo			char(50);
define _mensaje             char(50);
define _no_documento		char(20);
define _cod_grupo			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_perpago         char(3);
define _cod_ramo			char(3);
define _tipo_remesa			char(1);
define _prima_bruta_end		dec(16,2);
define _prima_bruta			dec(16,2);
define _porc_rech			dec(16,2);
define _descuento			dec(16,2);
define _saldo				dec(16,2);
define _pagado				dec(16,2);
define _valor               dec(16,2);
define _ult_pago            dec(16,2);
define _tipo_produccion		smallint;
define _facultativo			smallint;
define _declarativa			smallint;
define _existe_end			smallint;
define _existe_rev			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _cant_pag			smallint;
define _manzana				smallint;
define _es_soda				smallint;
define _flota				smallint;
define _saber               smallint;
define _dias				smallint;
define _cant				smallint;
define _fecha_suscripcion	date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

let _prima_bruta	= 0;
let _cod_compania	= '001';
let _cod_sucursal	= '001';
let _fecha_hoy      = null;
let _pagado         = 0.00;
let _valor          = 0.00;
let _mensaje        = '';
let _ult_pago       = 0;
let _saber          = 0;

--set debug file to "sp_sis402.trc";
--trace on;

if a_no_remesa is null then
	let a_no_remesa = '00000';
end if

select no_documento,
	   fecha_suscripcion,
	   cod_ramo,
	   cod_formapag,
	   cod_subramo,
	   prima_bruta,
	   cod_grupo,
	   vigencia_inic,
	   cod_tipoprod,
	   cod_perpago,
	   no_pagos,
	   declarativa,
	   fronting
  into _no_documento,
	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _cod_subramo,
	   _prima_bruta,
	   _cod_grupo,
	   _vigencia_inic,
	   _cod_tipoprod,
	   _cod_perpago,
	   _no_pagos,
	   _declarativa,
	   _fronting
  from emipomae
 where no_poliza = a_no_poliza;

--Determinar fecha del Pago
select --max(d.fecha),
       sum(d.monto)
  into --_fecha_hoy,
       _pagado
  from cobredet d, cobremae m
 where d.actualizado  = 1
   and d.cod_compania = '001'
   and d.doc_remesa   = _no_documento
   and d.tipo_mov     in ('P','N')
   and d.no_remesa    = m.no_remesa
   and d.no_poliza    = a_no_poliza
   and m.tipo_remesa  in ('A', 'M', 'C');

if a_fecha_hoy is null then
	let a_fecha_hoy = current;
end if

let _fecha_hoy = a_fecha_hoy;

if _pagado is null then
	let _pagado = 0;
end if

if _cod_grupo = '124' or  _cod_grupo = '125'  then --Banisi - Lizzy Bernal, Se adiciona Felix Abadia solicitud AMORENO:17/09/2018
	return 1,'El Grupo de la Póliza no Aplica para el descuento.',0.00;
end if   
   
--Calculo del Descuento
if _cod_grupo not in ('00967','01024','21212') then --Grupo Felix B Maduro y Grupo Do It Center
	let _descuento = (_prima_bruta * 0.05);
else
	let _descuento = (_prima_bruta * 0.07);
end if
----
--Aqui estoy poniendo que busque las condiciones de electronico desde recibos manual.  Armando 24/07/2013
if a_no_remesa = '00000' then
	let _tipo_remesa = 'A';
else
	select tipo_remesa
	  into _tipo_remesa
	  from cobremae
	 where no_remesa = a_no_remesa;
end if
 
if _tipo_remesa = 'A' then --Automaticas
	select count(*)
	  into _saber
	  from cobpronde
	 where no_poliza = a_no_poliza
	   and procesado = 0;
	
	if _saber = 0 then
		call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;
		if _valor = 0 then  --Aplica
			return 0,'SI APLICA AL DESCUENTO ELECTRONICO',_descuento;			
		end if
	else
		return 1,'El Descuento esta Por realizarce.',_descuento;
	end if
end if

--Excepcion de Coaseguros
select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion in (3) then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Coaseguro.";
	return 1,_error_desc,_descuento;
end if

if _fronting = 1 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Fronting.";
	return 1,_error_desc,_descuento;
end if

if _cod_perpago = '006' and _no_pagos = 1 then --pago inmediato no aplica pronto pago
	let _error_desc = "Póliza con pago INMEDIATO, NO APLICA.";
	return 1,_error_desc,_descuento;
end if

if _cod_ramo = '009' and _declarativa = 1 then --Excluye Pólizas Declarativa de Transporte
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Declarativa de Transporte.";
	return 1,_error_desc,_descuento;
end if

--Excepcion Facultativos
let _facultativo = 0;
let _facultativo = sp_sis439(a_no_poliza);

if _facultativo = 1 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Facultativa.";
	return 1,_error_desc,_descuento;
end if

--Excepcion de Ramos
if _cod_ramo in ('004','008','016','018','019','023') then
	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _error_desc = 'El Ramo ' || trim(_nom_ramo) || ' NO Aplica para este Descuento.';
	return 1,_error_desc,_descuento;
end if

if _fecha_suscripcion > _vigencia_inic then
	let _dias = _fecha_hoy - _fecha_suscripcion;
else
	let _dias = _fecha_hoy - _vigencia_inic;
end if

if _dias > 30 then
	let _error_desc = "La Póliza no cumple con las condiciones. Han pasado " || trim(cast(_dias as char(3))) || " días desde la Fecha de Suscripcion/Vigencia Inicial de la Póliza.";
	return 1,_error_desc,_descuento;
end if

if _pagado is null then
	let _pagado = 0;
end if

--if a_monto_pago = 0 then	--Vengo de Endoso
if _tipo_remesa = 'A' then
	let _valor = _prima_bruta - _descuento;
	let _pagado = _pagado + a_monto_pago;
	
	if abs(_pagado - _valor) > 0.03 then
		if _pagado < _valor then
			let _error_desc = 'No ha Completado el Pago Aun.';
			return 1, _error_desc, _descuento;
		end if
	end if
end if

--Pólizas con primas menores de bl. 350 no aplican
if _cod_grupo <> '1117' then
	if _prima_bruta <= 350 then
		let _error_desc = 'Esta póliza no aplica para este descuento. La prima es menor de b/.350.00.';
		return 1,_error_desc,_descuento;
	end if
end if

if (_cod_ramo in ('001') and _cod_subramo = '006') or (_cod_ramo in ('003') and _cod_subramo = '005') then
	let _error_desc = 'No Aplica. La Pólizas de Zona Libre/France Field no participan del descuento...';
	return 1,_error_desc,_descuento;
end if

--Verifica si la manzana es Zona Libre
call sp_pro857(a_no_poliza) returning _manzana;
if _manzana = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Unidad(es) con ubicación en Zona Libre.';
	return 1,_error_desc,_descuento;
end if

return 0,'SI APLICA',_descuento;

end procedure;