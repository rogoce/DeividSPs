-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec350;

create procedure sp_rec350()
returning char(20) 	as reclamo,
 		  integer	as error,
          date		as fecha_reclamo,
		  smallint	as dias,
		  dec(16,2)	as reserva_neta,
		  char(50)	as ramo,
		  char(50)	as ajustador,
		  char(10)	as transaccion,
		  varchar(50)	as tipo_tr,
		  date		as ult_fecha_tr,
		  date		as fecha_cierre;

define _fecha_inicio	date;
define _fecha_reclamo	date;
define _cantidad		smallint;
define _cantidad2       smallint;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _perd_total		smallint;
define _dias            integer;         
define _dias_tr         integer;         

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);
define _ult_fecha       date;
define _fecha_doc       date;
define _cod_abogado     char(3);
define _cont_tercero    smallint;
define _cod_ajustador   char(3);
define _n_ajustador     char(50);
define _cod_evento      char(3);
define _cod_tipotran    char(3);
define _no_tranrec      char(10);
define _tipotran        varchar(50);
define _transaccion     char(10);
define _incurrido_neto  dec(16,2);
define _variacion_neta  dec(16,2);

let _fecha_inicio = MDY(1,1,2015);
--let _fecha_inicio = MDY(1,11,2017);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;

foreach
	select fecha_reclamo,
           no_reclamo,
		   numrecla,
		   no_poliza,
		   perd_total,
		   no_tramite,
		   incidente,
		   cod_abogado,
		   user_added,
		   ajust_interno
      into _fecha_reclamo,
           _no_reclamo,
		   _numrecla,
		   _no_poliza,
		   _perd_total,
		   _no_tramite,
		   _incidente,
		   _cod_abogado,
		   _user_added,
		   _cod_ajustador
      from recrcmae
     where fecha_reclamo  >= _fecha_inicio
	   and actualizado    = 1
	   and numrecla[1,2] = '18'
	
	select max(fecha),
	       max(no_tranrec)
	  into _ult_fecha,
	       _no_tranrec
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado  = 1;
		   
	if (today - _ult_fecha) >= 31 then	
	else
		continue foreach;
	end if
	
	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	-- Solicitud de Katherine Cesar 27/03/2014
    if _cod_abogado is not null and _cod_abogado <> '001' then
		continue foreach;
	end if

	--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
	-- 	Modificado por Demetrio Hurtado


	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if

	if _reserva <= 0.00 then
		continue foreach;
	end if

	let _variacion_neta = sp_rec350b(_no_reclamo);
			
	-- Proceso que cierra las reservas
	
	select cod_tipotran,
	       transaccion
	  into _cod_tipotran,
	       _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;
	 
	select nombre
	  into _tipotran
	  from rectitra
	 where cod_tipotran = _cod_tipotran;	

    if _cod_tipotran = '001' then
		if _variacion_neta <= 1000.00 then
			call sp_rec350a(_no_reclamo,_reserva,'011') returning _error,_error_desc; 
		else
			continue foreach;
		end if
	else
		if _variacion_neta <> 0.00 then
			call sp_rec350a(_no_reclamo,_reserva,'003') returning _error,_error_desc; 
		else
			continue foreach;
		end if		
	end if

--	call sp_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;


	select nombre
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	return _numrecla,
		   _error,
		   _fecha_reclamo,
		   today - _ult_fecha,
 		   _variacion_neta,
		   _nombre_ramo,
		   _n_ajustador,
 		   _transaccion,
 		   _tipotran,
		   _ult_fecha,
		   today
		   with resume;

end foreach

return "",
	   0,
       "",
	   0,
	   0.00,
	   "",
	   "",
	   null,
	   null,
	   null,
	   null
	   with resume;

end procedure