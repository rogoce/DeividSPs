-- Procedimiento que actuliza los reclamos que no tienen
-- reserva con el valor de la reserva promedio

-- Creado    : 21/10/2008 - Autor: Amado Perez  

--drop procedure sp_rwf67;

create procedure sp_rwf67(a_no_reclamo char(10)) 
returning dec(16,2);

define _no_poliza               CHAR(10);
define _cod_compania, _cod_ramo CHAR(3);
define _periodo_rec             CHAR(7);
define _reserva_inicial         dec(16,2);
define _no_documento			char(20);
define _fecha                   date;
define _cod_evento				CHAR(3);
define _tipo, _cnt_cob          smallint;
define _suma_asegurada      	dec(16,2);
define _cod_cobertura           char(5);

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

let _fecha = current;
let _reserva_inicial = 0.00;
let _tipo = 1;
let _cnt_cob = 0;

set isolation to dirty read;

select no_poliza,
       cod_compania,
	   cod_evento, 
	   suma_asegurada,
	   periodo
  into _no_poliza,
       _cod_compania,
	   _cod_evento,
	   _suma_asegurada,
	   _periodo_rec
  from recrcmae
 where no_reclamo = a_no_reclamo;

--select rec_periodo
--  into _periodo_rec
--  from parparam
-- where cod_compania = _cod_compania;

select cod_ramo,
       no_documento
  into _cod_ramo,
       _no_documento
  from emipomae
 where no_poliza = _no_poliza;

if _cod_ramo = "023" then --> auto flotas
	let _cod_ramo = "002";
end if

--if _cod_ramo <> "018" then
--	return 0, "Actualizacion Exitosa";
--end if

if _no_documento = "0213-00525-04" then -- MetroBus

	let _reserva_inicial = 100;

else
   if _fecha >= "01/10/2013" and _cod_ramo = '002' then 
    foreach
		select reserva_inicial, tipo
		  into _reserva_inicial, _tipo
		  from recreeve
		 where cod_ramo = _cod_ramo
		   and periodo  <= _periodo_rec
		   and cod_evento = _cod_evento
		 order by periodo desc
		exit foreach;
	end foreach

	if _tipo = 2 then
		let _reserva_inicial = _suma_asegurada;
	end if

	if _reserva_inicial is null then
		let _reserva_inicial = 0.00;
	end if
   else	
	if _fecha >= "01/10/2013" and _cod_ramo = '020' then
		foreach
			select reserva
			  into _reserva_inicial
			  from recrepro
			 where cod_ramo = _cod_ramo
			   and periodo  <= _periodo_rec
		    order by periodo desc
			exit foreach;
		end foreach
	else
		select reserva
		  into _reserva_inicial
		  from recrepro
		 where cod_ramo = _cod_ramo
		   and periodo  = _periodo_rec;
	end if
   end if
end if

if _cod_evento = '016' then --Para polizas que no tengan cobertura de colision
    let _cnt_cob = 0;
	 
	select count(*)
	  into _cnt_cob
	  from recrccob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and no_reclamo = a_no_reclamo
	   and b.nombre like '%COLISION%';
	
	if _cnt_cob = 0 then 	      
		foreach
			select reserva
			  into _reserva_inicial
			  from recrepro
			 where cod_ramo = '020'
			   and periodo  <= _periodo_rec
		    order by periodo desc
			exit foreach;
		end foreach
	end if
end if

if _cnt_cob > 0 then
	update recrccob
		set reserva_inicial = _reserva_inicial,
			reserva_actual  = _reserva_inicial
	  where no_reclamo      = a_no_reclamo
		and cod_cobertura in (select cod_cobertura from prdcober where nombre like '%COLISION%') ;
else
	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from recrccob
	  where no_reclamo = a_no_reclamo

	 update recrccob
		set reserva_inicial = _reserva_inicial,
			reserva_actual  = _reserva_inicial
	  where no_reclamo      = a_no_reclamo
		and cod_cobertura   = _cod_cobertura;

	 exit foreach;

	end foreach
end if

return _reserva_inicial;

end procedure