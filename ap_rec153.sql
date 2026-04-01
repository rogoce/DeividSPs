-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure ap_rec153;

create procedure ap_rec153()
returning char(20) as Reclamo,
          date as fecha_reclamo,
		  smallint as error,
		  smallint as dias,
		  dec(16,2) as reserva_ini,
		  char(50) as ramo,
		  char(50) as ajustador,
		  char(10) as transaccion,
		  varchar(50) as tipo,
		  date as fecha_doc,
		  date as hoy;

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

let _fecha_inicio = MDY(1,1,2015);
--let _fecha_inicio = MDY(1,11,2017);

set isolation to dirty read;

--SET DEBUG FILE TO "ap_rec153.trc"; 
--trace on;


let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;


-- DRN-TBD203 -- CASO 7707 -- Amado 05-09-2023
foreach
   select a.fecha_reclamo,
          a.no_reclamo,
		  a.numrecla,
		  a.no_poliza,
		  a.perd_total,
		  a.no_tramite,
		  a.incidente,
		  a.user_added,
		  a.cod_abogado,
		  a.ajust_interno,
		  a.cod_evento,
		  b.cod_ramo
     into _fecha_reclamo,
          _no_reclamo,
		  _numrecla,
		  _no_poliza,
		  _perd_total,
		  _no_tramite,
		  _incidente,
		  _user_added,
		  _cod_abogado,
		  _cod_ajustador,
		  _cod_evento,
		  _cod_ramo
     from recrcmae a, emipomae b
    where a.no_poliza = b.no_poliza
      and a.fecha_reclamo  >= _fecha_inicio
	  and a.actualizado    = 1
	  and a.estatus_reclamo = 'A'
	and b.cod_ramo in ("002", "020", "023")		 --se incluye 023 01/10/2014 Armando

	let _cantidad = 0;
	
	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_tipotran not in ('001')
       and ((actualizado  = 1)
	    or (actualizado = 0
 	   and wf_aprobado = 3));
	   
		   
	if _cantidad > 0 then	-- Se procesarán las que solo tienen reserva inicial
		continue foreach;
	end if

	--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
	-- 	Modificado por Demetrio Hurtado

	if _perd_total = 1 then
		continue foreach;
	end if

    -- Solicitud de Analisa Stanziola 24/03/2014
	-- Modificado por Amado Perez
    if _cod_abogado is not null and _cod_abogado <> '001' then
		continue foreach;
	end if

	-- Verificando la reserva
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
		
	-- Atropello de Peatón
	if _cod_evento = '005' then -- Según DRN-TBD83 11/06/2021
		continue foreach;
	end if	

    -- Buscando la última fecha de actualización de documento	
	let _cantidad = 0;

    let _ult_fecha = null;
	
	select max(date_added)
	  into _ult_fecha
      from recrcdoc
     where no_reclamo = _no_reclamo;	  
	
	if _ult_fecha is null then
		let _ult_fecha = today; 
	end if 
	 
	select count(*)
	  into _cantidad
      from recterce
     where no_reclamo = _no_reclamo;
	 
	let _fecha_doc = null; 

    if _cantidad > 0 then
		select max(date_added)
		  into _fecha_doc
		  from recterdoc
		 where no_reclamo = _no_reclamo; 
		 
		if _fecha_doc is null then
			let _fecha_doc = today; 
		end if 		 
		 
		if _fecha_doc > _ult_fecha then
			let _ult_fecha = _fecha_doc;
        end if		
	end if	
	
	let _dias_tr = today - _ult_fecha;
	
	if _dias_tr > 90 then 
		   
--	if _fecha_reclamo <> _ult_fecha then 
		-- Proceso que cierra las reservas
		select cod_tipotran,
			   transaccion
		  into _cod_tipotran,
			   _transaccion
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and cod_tipotran = '001';
		
		select nombre
		  into _tipotran
		  from rectitra
		 where cod_tipotran = _cod_tipotran;	  

	--	call sp_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		-- Inserta info en wfcieres para abortar los incidentes del mapa de control reclamos poliza.	Armando 19/10/2010
	--	insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
	--	values(_no_reclamo,_no_tramite,_incidente,_user_added);

		select nombre
		  into _n_ajustador
		  from recajust
		 where cod_ajustador = _cod_ajustador;
				
		return _numrecla,
			   _fecha_reclamo,
			   _error,
			   _dias_tr,
			   _reserva,
			   _nombre_ramo,
			   _n_ajustador,
			   _transaccion,
			   _tipotran,
			   _ult_fecha,
			   today
			   with resume;
 --   end if
	
	end if
	
end foreach

return "",
       "",
	   0,
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