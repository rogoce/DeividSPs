-- Procedimiento que verifica los cheques en firma
 
-- Creado     :	13/01/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che122;		

create procedure "informix".sp_che122()
returning char(50),
		  date,
		  smallint;

define _firma1				varchar(20);
define _firma2				varchar(20);
--define _fecha				date;
define _cantidad			smallint;
define _cantidad_total		smallint;
define _cantidad_final		smallint;
define _nombre				char(50);
							
define _fecha_paso_firma	date;
define _fecha_firma1	 	date;

set isolation to dirty read;

create temp table tmp_firmas(
usuario		varchar(20),
fecha		date,
cantidad	smallint
) with no log;

foreach
 select	firma1,
        firma2,
		fecha_paso_firma,
		fecha_firma1
   into _firma1,
        _firma2,
		_fecha_paso_firma,
		_fecha_firma1
   from chqchmae
  where pagado           = 0
    and en_firma         <> 2
    and fecha_paso_firma is not null

	if _firma2 is null or
	   _firma2 =  ""   then

		insert into tmp_firmas
		values (_firma1, _fecha_paso_firma, 1); 

	else

		insert into tmp_firmas
		values (_firma2, _fecha_firma1, 1); 

	end if


--and (firma1 = "AGOMEZ" or
--     firma2 = "AGOMEZ")
--order by fecha_firma1, fecha_paso_firma

end foreach

let _firma2         = null;
let _cantidad_total = 0;
let _cantidad_final = 0;

foreach 
 select usuario,
        fecha,
		sum(cantidad)
   into _firma1,
		_fecha_firma1,
		_cantidad
   from tmp_firmas
  group by 1, 2
  order by 1, 2

	if _firma2 is not null then

		if _firma1 <> _firma2 then 
		
			return "Total",
				   null,
				   _cantidad_total
				   with resume;

			return null,
				   null,
				   null
				   with resume;

			let _cantidad_total = 0;
			let _firma2         = null;

		end if
		 
	end if

	let _cantidad_total = _cantidad_total + _cantidad;
	let _cantidad_final = _cantidad_final + _cantidad;

    if _firma1 is not null and trim(_firma1) <> "" then
		select descripcion
		  into _nombre
		  from insuser
		 where windows_user = _firma1;
	else
		let _nombre = 'Error';
	end if
	
	if _firma2 is null then

		return trim(_nombre) || "  (" || trim(_firma1) || ")",
			   null,
			   null
			   with resume;

	end if

	return null,
		   _fecha_firma1,
		   _cantidad
		   with resume;

	let _firma2 = _firma1;

end foreach

drop table tmp_firmas;

return "Total",
	   null,
	   _cantidad_total
	   with resume;

return null,
	   null,
	   null
	   with resume;

return "Total Final",
	   null,
	   _cantidad_final;

end procedure
