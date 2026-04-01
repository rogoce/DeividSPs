--  Procedimiento para determinar si una poliza aplica o no para el descuento de 5% 
-- Creado: 15/02/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis402bk2;
create procedure sp_sis402bk2(a_no_poliza char(10),a_fecha_hoy date, a_monto_pago decimal(16,2) default 0, a_no_remesa char(10))
returning	smallint,
			varchar(120),
			decimal(16,2);

define _error_desc			varchar(120);
define _nom_ramo			char(50);
define _no_documento		char(20);
define _cod_grupo			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tipo_remesa			char(1);
define _prima_bruta_end		dec(16,2);
define _prima_bruta			dec(16,2);
define _porc_rech			dec(16,2);
define _descuento			dec(16,2);
define _saldo				dec(16,2);
define _pagado				dec(16,2);
define _valor               dec(16,2);
define _facultativo			smallint;
define _existe_end			smallint;
define _existe_rev			smallint;
define _cant_pag			smallint;
define _manzana				smallint;
define _es_soda				smallint;
define _flota				smallint;
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

--set debug file to "sp_sis402.trc";
--trace on;

select no_documento,
	   fecha_suscripcion,
	   cod_ramo,
	   cod_formapag,
	   cod_subramo,
	   prima_bruta,
	   cod_grupo,
	   vigencia_inic
  into _no_documento,
	   _fecha_suscripcion,
	   _cod_ramo,
	   _cod_formapag,
	   _cod_subramo,
	   _prima_bruta,
	   _cod_grupo,
	   _vigencia_inic
  from emipomae
 where no_poliza = a_no_poliza;

--Determinar fecha del Pago
select max(d.fecha),
       sum(d.monto)
  into _fecha_hoy,
       _pagado
  from cobredet d, cobremae m
 where d.actualizado  = 1
   and d.cod_compania = '001'
   and d.doc_remesa   = _no_documento
   and d.tipo_mov     in ('P','N')
   and d.no_remesa    = m.no_remesa
   and d.no_poliza    = a_no_poliza
   and m.tipo_remesa  in ('A', 'M', 'C');

if _fecha_hoy is null then
	let _fecha_hoy = a_fecha_hoy;
end if

{select prima_bruta
  into _prima_bruta_end
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = '00000';}

--Calculo del Descuento
if _cod_grupo not in ('00967','01024','21212') then --Grupo Felix B Maduro y Grupo Do It Center
	let _descuento = (_prima_bruta * 0.05);
else
	let _descuento = (_prima_bruta * 0.07);
end if

select count(*)
  into _facultativo
  from emifafac
 where no_poliza = a_no_poliza;
 
if _facultativo > 0 then
	let _error_desc = "La Póliza no cumple con las condiciones. La Póliza es Facultativa.";
	return 1,_error_desc,_descuento;
end if

--Excepcion de Ramos
if _cod_ramo in ('004','008','016','018','019','020') then
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

if a_no_remesa = '00000' then
	let _tipo_remesa = 'A';
else
	select tipo_remesa
	  into _tipo_remesa
	  from cobremae
	 where no_remesa = a_no_remesa;
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

select count(*)
  into _flota
  from emipouni
 where no_poliza = a_no_poliza;
 
if _flota > 1 then
	let _error_desc = 'No Participan Flotas.';
	return 1,_error_desc,_descuento;
end if

{-- No Aplican las Pólizas de Pago Electrónico
if _cod_formapag in ('003','005') then --Forma de pagos electronicas
	let _error_desc = 'La Forma de Pago de la Póliza NO Aplica para el Descuento.';
	return 1,_error_desc,_descuento;
end if}

--Verifica si ya se le aplico descuento de pronto pago
{select count(*)
  into _existe_end
  from endedmae
 where no_poliza	= a_no_poliza
   and cod_endomov	= '024'
   and actualizado  = 1;

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza	= a_no_poliza
   and cod_endomov	= '025'
   and actualizado  = 1;

if (_existe_end - _existe_rev) > 0 then
	let _error_desc = 'Esta póliza ya tiene el endoso de descuento aplicado, Por Favor Verifique...';
	return 2,_error_desc,_descuento;
end if }

--Pólizas con primas menores de bl. 100 no aplican
if _prima_bruta <= 100 then
	let _error_desc = 'Esta póliza no aplica para este descuento. La prima es menor de b/.100.00.';
	return 1,_error_desc,_descuento;
end if

{--Verifica el saldo de la Póliza
call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento, "") returning _saldo;

if _saldo < 0 then
	let _error_desc = 'Esta póliza no aplica para este descuento.Tiene un saldo menor a 0.';
	return 1,_error_desc,_descuento;
end if}

--Verifica si es póliza SODA
call sp_pro861(a_no_poliza) returning _es_soda;
if _es_soda = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Es una Póliza SODA.';
	return 1,_error_desc,_descuento;
end if

--Verifica si la manzana es Zona Libre
call sp_pro857(a_no_poliza) returning _manzana;
if _manzana = 1 then
	let _error_desc = 'Esta póliza no aplica para este descuento. Unidad(es) con ubicación en Zona Libre.';
	return 1,_error_desc,_descuento;
end if

return 0,'SI APLICA',_descuento;

end procedure