-- Procedimiento que determina los reclamos promedios de los ultimos tres meses.A utomovil usadito

-- Creado    : 13/05/2013 - Autor: rmando Moreno

drop procedure sp_rec160b;

create procedure sp_rec160b(a_periodo char(7)) 
returning	char(3),
			char(5),
			char(5),
			char(7),
			dec(16,2),
			integer,
			dec(16,2);

define _nombre_icd		char(50);
define _error_desc		char(50);
define _numrecla		char(20);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_icd			char(10);
define _periodo_rec		char(7);
define _periodo_2		char(7);
define _periodo_3		char(7);
define _periodo_4		char(7);
define _cod_cobertura	char(5);
define _cod_producto	char(5);
define _no_unidad		char(5);
define _cod_ramo		char(3);
define _reserva			dec(16,2);
define _monto			dec(16,2);
define _perd_total		smallint;
define _cantidad		smallint;
define _ano				smallint;
define _mes				smallint;
define _error_isam		integer;
define _error			integer;

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];

begin
{on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception}


--SET DEBUG FILE TO "sp_rec160b.trc"; 
--trace on;


-- Periodo 2

if _mes = 1 then
	let _ano = _ano - 1;
	let _mes = 12;
else
	let _mes = _mes -1;
end if

if _mes < 10 then
	let _periodo_2 = _ano || "-0" || _mes;
else
	let _periodo_2 = _ano || "-" || _mes;
end if

-- Periodo 3

if _mes = 1 then
	let _ano = _ano - 1;
	let _mes = 12;
else
	let _mes = _mes -1;
end if

if _mes < 10 then
	let _periodo_3 = _ano || "-0" || _mes;
else
	let _periodo_3 = _ano || "-" || _mes;
end if

-- Periodo 4

if _mes = 1 then
	let _ano = _ano - 1;
	let _mes = 12;
else
	let _mes = _mes -1;
end if

if _mes < 10 then
	let _periodo_4 = _ano || "-0" || _mes;
else
	let _periodo_4 = _ano || "-" || _mes;
end if

-- Periodo Reclamo

select rec_periodo
  into _periodo_rec
  from parparam
 where cod_compania = "001";

{delete from recrepro2
 where periodo = _periodo_rec;}

create temp table tmp_promedio(
numrecla		char(20),
cod_ramo		char(3),
cod_producto	char(5),
cod_cobertura	char(5),
monto			dec(16,2),
primary key (numrecla,cod_producto,cod_cobertura)
) with no log;
  
foreach
	select no_tranrec,
		   no_reclamo,
		   perd_total
	  into _no_tranrec,
		   _no_reclamo,
		   _perd_total
	  from rectrmae
	 where periodo      in (a_periodo, _periodo_2, _periodo_3,_periodo_4)
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and monto        <> 0.00

	select no_poliza,
		   no_unidad,
	       cod_icd,
		   numrecla
	  into _no_poliza,
		   _no_unidad,
	       _cod_icd,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	   
	if _cod_producto <> '00290' or _cod_producto is null then
		continue foreach;
	end if
	 
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> '002' then	  --solo automovil
		continue foreach;
	end if

	-- No incluye las perdidas totales
	-- para autos y sodas
	
	if _cod_ramo in ("002") then
		if _perd_total = 1 then
			continue foreach;
		end if
	end if

	foreach
		select cod_cobertura,
			   monto
		  into _cod_cobertura,
			   _monto
		  from rectrcob
		 where no_tranrec = _no_tranrec
	
		select count(*)
		  into _cantidad
		  from tmp_promedio
		 where numrecla      = _numrecla
		   and cod_cobertura = _cod_cobertura
		   and cod_producto  = _cod_producto;

		if _cantidad = 0 then
			insert into tmp_promedio
			values (_numrecla, _cod_ramo,_cod_producto,_cod_cobertura, _monto);
		else
			update tmp_promedio
			   set monto    = monto + _monto
			 where numrecla = _numrecla
			   and cod_cobertura = _cod_cobertura;
		end if
	end foreach
end foreach

foreach
	select cod_ramo,
		   cod_cobertura,
		   cod_producto,
		   count(*),
		   sum(monto)
	  into _cod_ramo,
		   _cod_producto,
		   _cod_cobertura,
		   _cantidad,
		   _monto
	  from tmp_promedio
	 group by 1,2,3
	 order by 1,2,3

	let _reserva = _monto / _cantidad;

	return	_cod_ramo,
			_cod_producto,
			_cod_cobertura,
			_periodo_rec,
			_reserva,
			_cantidad,
			_monto with resume;
end foreach
drop table tmp_promedio;
end

--return 0, "Actualizacion Exitosa";

end procedure

