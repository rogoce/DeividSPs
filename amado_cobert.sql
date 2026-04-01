-- Procedimiento que actuliza los reclamos que no tienen
-- reserva con el valor de la reserva promedio

-- Creado    : 04/07/2008 - Autor: Amado Perez  

drop procedure amado_cobert;

create procedure amado_cobert(a_no_reclamo char(10)) 
returning integer,
          char(50);

define _periodo_rec		char(7);
define _cod_ramo		char(3);
define _no_poliza		char(10);
define _cantidad		smallint;
define _cod_compania	char(3);
define _cod_cobertura	char(5);
define _reserva_inicial	dec(16,2);
define _variacion		dec(16,2);
define _no_tranrec		char(10);
define _filas		    smallint;
define _null			char(1);

--return 0, "Actualizacion Exitosa";
let _null        = null;

select count(*)
  into _cantidad
  from recrccob
 where no_reclamo = a_no_reclamo;

if _cantidad = 0 then
	return 1, "No Hay Coberturas para la Reserva";
end if

{select sum(reserva_inicial)
  into _reserva_inicial
  from recrccob
 where no_reclamo = a_no_reclamo;

--if _reserva_inicial <> 0 then
--	return 0, "Actualizacion Exitosa";
--end if
 }
select no_poliza,
--       periodo,
       cod_compania
  into _no_poliza,
--       _periodo_rec,
       _cod_compania
  from recrcmae
 where no_reclamo = a_no_reclamo;

select rec_periodo
  into _periodo_rec
  from parparam
 where cod_compania = _cod_compania;

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
   and periodo  = _periodo_rec;

foreach
 select cod_cobertura
   into _cod_cobertura
   from recrccob
  where no_reclamo = a_no_reclamo
    and reserva_inicial = _reserva_inicial

 {	update recrccob
	   set reserva_inicial = _reserva_inicial,
	       reserva_actual  = _reserva_inicial
	 where no_reclamo      = a_no_reclamo
	   and cod_cobertura   = _cod_cobertura;
  }
	exit foreach;

end foreach
{
update recrcmae
   set reserva_inicial = _reserva_inicial,
       reserva_actual  = _reserva_inicial
 where no_reclamo      = a_no_reclamo;

-- Para los casos que se actualizan por WF con reserva en 0 y luego
-- se completan en Deivid a traves de la opcion de Tramite
}
if _cod_ramo in ("002", "020") then
  FOREACH 
	select no_tranrec,
	       variacion
	  into _no_tranrec,
	       _variacion
	  from rectrmae
	 where no_reclamo   = a_no_reclamo
	   and cod_tipotran = "001"
	order by 1 desc
	exit foreach;
  END FOREACH
	   
 --	if _variacion = 0.00 then

		update rectrmae
		   set monto        = _reserva_inicial,
		       variacion    = _reserva_inicial
		 where no_tranrec   = _no_tranrec;

	   let _filas = 0;

       select count(*) into _filas from rectrcob where no_tranrec = _no_tranrec and cod_cobertura = _cod_cobertura;

       If _filas = 0 Then
			insert into rectrcob(
			no_tranrec,
			cod_cobertura,
			monto,
			variacion,
			facturado,
			elegible,
			a_deducible,
			co_pago,
			cod_no_cubierto,
			monto_no_cubierto,
			cod_tipo,
			coaseguro,
			ahorro
			)
			select
			_no_tranrec,
			cod_cobertura,
			0.00, -- reserva_inicial,
			0.00, -- reserva_inicial,
			0.00,
			0.00,
			0.00,
			0.00,
			_null,
			0.00,
			_null,
			0.00,
			0.00
			from recrccob
			where no_reclamo = a_no_reclamo and cod_cobertura = _cod_cobertura;
	   End If

		update rectrcob
		   set monto         = _reserva_inicial,
		       variacion     = _reserva_inicial
		 where no_tranrec    = _no_tranrec
	       and cod_cobertura = _cod_cobertura;

 --	end if

end if

return 0, "Actualizacion Exitosa";

end procedure