-- Procedimiento que determina los reclamos promedios de los ultimos tres meses

-- Creado    : 02/07/2008 - Autor: Amado Perez 
-- Modificado: 27/09/2013 - Autor: Amado Perez -- Se excluye automovil 

drop procedure sp_rec160;

create procedure sp_rec160(a_periodo char(7)) 
returning integer,
          char(50);

define _periodo_2	char(7);
define _periodo_3	char(7);
define _periodo_rec	char(7);
define _ano			smallint;
define _mes			smallint;

define _no_reclamo	char(10);
define _no_poliza	char(10);
define _cod_ramo	char(3);
define _cod_icd		char(10);
define _nombre_icd	char(50);
define _perd_total	smallint;
define _numrecla	char(20);
define _cantidad	smallint;
define _monto		dec(16,2);
define _reserva		dec(16,2);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

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

-- Periodo Reclamo

select rec_periodo
  into _periodo_rec
  from parparam
 where cod_compania = "001";

delete from recrepro
 where periodo = _periodo_rec
   and cod_ramo <> '020';

create temp table tmp_promedio(
numrecla	char(20),
cod_ramo	char(3),
monto		dec(16,2),
primary key (numrecla)
) with no log;
  
foreach
 select	no_reclamo,
		monto
   into	_no_reclamo,
		_monto
   from rectrmae
  where periodo      in (a_periodo, _periodo_2, _periodo_3)
    and actualizado  = 1
	and cod_tipotran = "004"
	and monto        <> 0.00

	select no_poliza,
	       cod_icd,
		   perd_total,
		   numrecla
	  into _no_poliza,
	       _cod_icd,
		   _perd_total,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Verifica los diagnosticos de embarazo para salud
	-- No entran en el proceso

	if _cod_ramo = "018" then

		select nombre
		  into _nombre_icd
		  from recicd
		 where cod_icd = _cod_icd;

		if _nombre_icd[1,8] = "EMBARAZO" then
			continue foreach;
		end if

	end if

	-- No incluye las perdidas totales para sodas

	if _cod_ramo = "002" or _cod_ramo = "020" then  --> Para automovil se utilizara la tabla recreeve y no se calcula soda 27-09-2013
			continue foreach;
	end if


	if _cod_ramo = "020" then

		if _perd_total = 1 then
			continue foreach;
		end if

	end if

	select count(*)
	  into _cantidad
	  from tmp_promedio
	 where numrecla = _numrecla;

	if _cantidad = 0 then

		insert into tmp_promedio
		values (_numrecla, _cod_ramo, _monto);

	else

		update tmp_promedio
		   set monto    = monto + _monto
	 	 where numrecla = _numrecla;

	end if

end foreach

foreach
 select cod_ramo,
        count(*),
		sum(monto)
   into _cod_ramo,
        _cantidad,
		_monto
   from tmp_promedio
  group by 1
  order by 1

	let _reserva = _monto / _cantidad;

	insert into recrepro(
	cod_ramo,
	periodo,
	reserva,
	cantidad,
	monto
	)
	values(
	_cod_ramo,
	_periodo_rec,
	_reserva,
	_cantidad,
	_monto
	);

end foreach

drop table tmp_promedio;

end 

return 0, "Actualizacion Exitosa";

end procedure

