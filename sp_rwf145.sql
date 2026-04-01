-- Procedimiento que actuliza los reclamos que no tienen
-- reserva con el valor de la reserva promedio

-- Creado    : 21/10/2008 - Autor: Amado Perez  

--drop procedure sp_rwf67;

create procedure sp_rwf145(a_no_poliza char(10), a_no_unidad char(5), a_cod_evento char(3)) 
returning dec(16,2);

define _cod_compania, _cod_ramo CHAR(3);
define _periodo_rec             CHAR(7);
define _reserva_inicial         dec(16,2);
define _no_documento			char(20);
define _fecha                   date;
define _tipo, _cnt_cob          smallint;
define _suma_asegurada      	dec(16,2);
define _cod_cobertura           char(5);
define _ano_s                   char(4);
define _mes_s                   char(2);

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

let _fecha = current;
let _reserva_inicial = 0.00;
let _tipo = 1;
let _ano_s = year(_fecha);

if month(_fecha) < 10 then
	let _mes_s = '0' || month(_fecha);
else
    let _mes_s = month(_fecha);
end if

let _periodo_rec = _ano_s || "-" || _mes_s;

set isolation to dirty read;

select cod_ramo,
       no_documento
  into _cod_ramo,
       _no_documento
  from emipomae
 where no_poliza = a_no_poliza;
 
select suma_asegurada
  into _suma_asegurada
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

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
		   and cod_evento = a_cod_evento
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

if a_cod_evento = '016' then --Para polizas que no tengan cobertura de colision
    let _cnt_cob = 0;
	 
	select count(*)
	  into _cnt_cob
	  from emipocob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_poliza = a_no_poliza
	   and a.no_unidad = a_no_unidad
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

return _reserva_inicial;

end procedure