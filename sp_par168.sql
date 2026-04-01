-- Procedimiento que actualiza los corredores

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par168;

create procedure "informix".sp_par168(
a_agente_viejo	char(5),
a_agente_nuevo	char(5),
a_fecha			date,
a_usuario		char(8)
) returning integer,
            integer,
            char(50);

define _no_remesa	char(10);
define _renglon		smallint;
define _contador	smallint;
define _no_poliza	char(10);
define _error       integer;
define _saldo, _monto  dec(16,2);
define _cod_ramo    char(5);

let _contador = 0;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_par168.trc";
--TRACE ON;

begin

ON EXCEPTION SET _error 
 	RETURN _error, 0, 'Error al Actualizar los Registros';         
END EXCEPTION           


foreach
 select d.no_remesa,
        d.renglon
   into _no_remesa,
		_renglon
   from cobreagt a, cobredet d
  where a.no_remesa   = d.no_remesa
    and a.renglon     = d.renglon
    and d.fecha      >= a_fecha
    and d.actualizado = 1
    and a.cod_agente  = a_agente_viejo

	let _contador = _contador + 1;

	update cobreagt
	   set cod_agente = a_agente_nuevo
	 where no_remesa  = _no_remesa
	   and renglon    = _renglon;

	Insert Into agthisun(
		cod_documento,
		tipo_doc,
	 	renglon,
		cod_agente_v,
		cod_agente_n,
		a_partir_de,
		fecha,
		user_added
		) 
		Values(
		_no_remesa,
		2,
		_renglon,
		a_agente_viejo,
		a_agente_nuevo,
		a_fecha,
		current,
		a_usuario
		);

end foreach


foreach
 select d.no_poliza
   into _no_poliza
   from emipoagt a, emipomae d
  where a.no_poliza          = d.no_poliza
    and d.fecha_suscripcion >= a_fecha
    and d.actualizado        = 1
    and a.cod_agente         = a_agente_viejo

	let _contador = _contador + 1;

	update emipoagt
	   set cod_agente = a_agente_nuevo
	 where no_poliza  = _no_poliza;

	Insert Into agthisun(
		cod_documento,
		tipo_doc,
		cod_agente_v,
		cod_agente_n,
		a_partir_de,
		fecha,
		user_added
		) 
		Values(
		_no_poliza,
		1,
		a_agente_viejo,
		a_agente_nuevo,
		a_fecha,
		current,
		a_usuario
		);

end foreach


select saldo
  into _saldo
  from agtagent
 where cod_agente = a_agente_viejo;

update agtagent 
   set saldo = saldo + _saldo
 where cod_agente = a_agente_nuevo;

update agtagent 
   set saldo = 0
 where cod_agente = a_agente_viejo;


foreach
	Select cod_ramo,
	       monto
	  Into _cod_ramo,
	       _monto
	  from agtsalra
	 where cod_agente = a_agente_viejo

begin
	ON EXCEPTION IN(-239,-268)                     
	                                          
		UPDATE agtsalra                       
		   SET monto      = monto + _monto 
		 WHERE cod_agente = a_agente_nuevo      
		   AND cod_ramo   = _cod_ramo;        
                                          
                                          
	END EXCEPTION                             
                                          
	INSERT INTO agtsalra(                     
	cod_agente,                               
	cod_ramo,                                 
	monto                                     
	)                                         
	VALUES(                                   
	a_agente_nuevo,                             
	_cod_ramo,                                
	_monto                                 
	);                                        

end

end foreach

begin
ON EXCEPTION SET _error 
 	RETURN _error, 0, 'Error al Actualizar los Registros';         
END EXCEPTION           

	update agtsalra 
	   set monto = 0
	 where cod_agente = a_agente_viejo;
end


end

return 0, _contador, " Registros Actualizados ...";

end procedure
