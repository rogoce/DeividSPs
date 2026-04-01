-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 04/09/2006 - Autor: Armando Moreno

drop procedure sp_che64b;

create procedure sp_che64b(a_no_requis char(10))
 returning char(8),
		   char(8),
		   smallint;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _fecha_captura   date;
define _dias            integer;
define _fecha_firma1	datetime year to fraction(5);
define _fecha_firma2	datetime year to fraction(5);
define _fecha_time		datetime year to fraction(5);
define _fecha_hoy_time	datetime year to fraction(5);
define _estatus			smallint;
define _saber			smallint;

SET ISOLATION TO DIRTY READ;

let _fecha_hoy_time = CURRENT;

 select	count(*)
   into	_saber
   from	chqchmae
  where no_requis     = a_no_requis
    and anulado       = 0
    and autorizado    = 1
    and pagado		  = 0
	and en_firma      = 2;

if _saber > 0 then	--esta por imprimir

	return "",
		   "",
		   3;
end if

 select	count(*)
   into	_saber
   from	chqchmae
  where no_requis     = a_no_requis
    and anulado       = 0
    and autorizado    = 1
    and pagado		  = 0
	and en_firma      = 1;

if _saber > 0 then	--esta en firma
else
	return "",
		   "",
		   0;
end if

select	firma1,
		firma2,
		fecha_firma1,
		fecha_firma2
   into	_firma1,
		_firma2,
		_fecha_firma1,
		_fecha_firma2
   from	chqchmae
  where no_requis     = a_no_requis
    and anulado       = 0
    and autorizado    = 1
    and pagado		  = 0
	and en_firma      = 1;

 let _estatus = 0;

 if _firma2 is null then
	let _firma2 = "";
 end if

 if _fecha_firma1 is null and _fecha_firma2 is null then
	let _estatus = 1;	--esta en firma1
 end if

 if _fecha_firma1 is not null and _fecha_firma2 is null then
	let _estatus = 2;	--esta en firma2
 end if

return _firma1,
	   _firma2,
	   _estatus;

end procedure
