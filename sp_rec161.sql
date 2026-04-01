-- Procedimiento que actualiza los reclamos que no tienen
-- reserva con el valor de la reserva promedio

-- Creado    : 04/07/2008 - Autor: Amado Perez  

drop procedure sp_rec161;

create procedure sp_rec161(a_no_reclamo char(10)) 
returning integer,
          char(50);

define _periodo_rec		char(7);
define _cod_ramo		char(3);
define _no_poliza		char(10);
define _cantidad		smallint;
define _cod_compania	char(3);
define _cod_cobertura	char(5);
define _reserva_inicial	dec(16,2);
define _reserva_inicial_cob	dec(16,2);
define _variacion		dec(16,2);
define _no_tranrec		char(10);
define _cod_evento      char(3);
define _suma_asegurada  dec(16,2);
define _tipo            smallint;
define _fecha           date;
define _tipo_dano       smallint;

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

let _fecha = current;

select count(*)
  into _cantidad
  from recrccob
 where no_reclamo = a_no_reclamo;

if _cantidad = 0 then
	return 1, "No Hay Coberturas para la Reserva";
end if

select sum(reserva_inicial)
  into _reserva_inicial_cob
  from recrccob
 where no_reclamo = a_no_reclamo;

--if _reserva_inicial <> 0 then
--	return 0, "Actualizacion Exitosa";
--end if

select no_poliza,
       cod_compania,
	   periodo,
	   cod_evento,
	   suma_asegurada,
	   tipo_dano
  into _no_poliza,
       _cod_compania,
	   _periodo_rec,
	   _cod_evento,
	   _suma_asegurada,
	   _tipo_dano
  from recrcmae
 where no_reclamo = a_no_reclamo;

--select rec_periodo
--  into _periodo_rec
--  from parparam
-- where cod_compania = _cod_compania;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

--if _cod_ramo <> "018" then
--	return 0, "Actualizacion Exitosa";
--end if
	
select reserva
  into _reserva_inicial
  from recrepro
 where cod_ramo = _cod_ramo
   and periodo  = _periodo_rec
   and tipo_dano = _tipo_dano;

foreach
 select cod_cobertura
   into _cod_cobertura
   from recrccob
  where no_reclamo = a_no_reclamo

	if _reserva_inicial_cob = 0 then
		update recrccob
		   set reserva_inicial = _reserva_inicial,
		       reserva_actual  = _reserva_inicial
		 where no_reclamo      = a_no_reclamo
		   and cod_cobertura   = _cod_cobertura;
	end if

	exit foreach;

end foreach

if _reserva_inicial_cob = 0 then
	update recrcmae
	   set reserva_inicial = _reserva_inicial,
	       reserva_actual  = _reserva_inicial
	 where no_reclamo      = a_no_reclamo;
end if

-- Para los casos que se actualizan por WF con reserva en 0 y luego
-- se completan en Deivid a traves de la opcion de Tramite

if _cod_ramo in ("002", "020") then
   if _fecha >= "01/10/2013" and _cod_ramo = '002' then 
    foreach
		select reserva_inicial, tipo
		  into _reserva_inicial, _tipo
		  from recreeve
		 where cod_ramo = _cod_ramo
		   and periodo  <= _periodo_rec
		   and cod_evento = _cod_evento
		   and tipo_dano = _tipo_dano
		 order by periodo desc
		exit foreach;
	end foreach

	if _tipo = 2 then
		let _reserva_inicial = _suma_asegurada;
	end if

   else	
	if _fecha >= "01/10/2013" and _cod_ramo = '020' then
		foreach
			select reserva
			  into _reserva_inicial
			  from recrepro
			 where cod_ramo = _cod_ramo
			   and periodo  <= _periodo_rec
			   and tipo_dano = _tipo_dano
		    order by periodo desc
			exit foreach;
		end foreach
	end if
   end if

	if _reserva_inicial is null then
		let _reserva_inicial = 0.00;
	end if

	select no_tranrec,
	       variacion
	  into _no_tranrec,
	       _variacion
	  from rectrmae
	 where no_reclamo   = a_no_reclamo
	   and cod_tipotran = "001";
	   
	if _variacion = 0.00 then

		update rectrmae
		   set monto        = _reserva_inicial,
		       variacion    = _reserva_inicial,
			   periodo      = _periodo_rec,
			   sac_asientos = 0,
			   subir_bo     = 1
		 where no_tranrec   =  _no_tranrec;

		update rectrcob
		   set monto         = _reserva_inicial,
		       variacion     = _reserva_inicial
		 where no_tranrec    =  _no_tranrec
	       and cod_cobertura = _cod_cobertura;

	end if

end if

return 0, "Actualizacion Exitosa";

end procedure