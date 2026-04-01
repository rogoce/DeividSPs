drop PROCEDURE sp_rec148b;
CREATE PROCEDURE sp_rec148b(a_aprob char(10))
returning varchar(200);

define _cod_reclamante,_cod_asegurado,_no_poliza	     char(10);
define _no_documento	     char(20);
define _no_unidad 			 char(5);
define _cont                 smallint;
define _exclusion            varchar(200);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rec148b.trc";
--trace on;

SELECT  cod_reclamante,				
		no_documento
  INTO  _cod_reclamante,   			
		_no_documento
   FROM recprea1			             
  WHERE no_aprobacion = a_aprob;

 call sp_sis21(_no_documento) returning _no_poliza;
 
 let _cont = 0;
 
 select count(*)
   into _cont
	from emipouni 
   where no_poliza 		= _no_poliza
	 and cod_asegurado 	= _cod_reclamante;
	 
if _cont is null then
	let _cont = 0;
end if		
 
if _cont > 1 then
	 select no_unidad 
	   into _no_unidad
		from emipouni 
	   where no_poliza 		= _no_poliza
		 and cod_asegurado 	= _cod_reclamante
		 and activo = 1;
else
	 select no_unidad 
	   into _no_unidad
		from emipouni 
	   where no_poliza 		= _no_poliza
		 and cod_asegurado 	= _cod_reclamante;
end if
if _no_unidad is null then
	foreach
		select no_unidad
		  into _no_unidad
		  from emidepen
		 where no_poliza   = _no_poliza
		   and cod_cliente = _cod_reclamante
		   
		exit foreach;
	end foreach	
end if

select cod_asegurado
  into _cod_asegurado
  from emipouni 
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad;

let _cont = 0;
if _cod_reclamante = _cod_asegurado then
 
	foreach
		SELECT emiproce.nombre
		  into _exclusion
		  FROM emipreas,emiproce,emipouni
		 WHERE emiproce.cod_procedimiento = emipreas.cod_procedimiento
		   and emipouni.no_poliza = emipreas.no_poliza
		   and emipouni.no_unidad = emipreas.no_unidad
		   and emipouni.no_poliza = _no_poliza
		   and emipouni.no_unidad = _no_unidad

		if _cont = 5 then
			exit foreach;
		end if	
		return _exclusion with resume;
		let _cont = _cont + 1;
	end foreach
else
	foreach
		SELECT emiproce.nombre
		  into _exclusion
		  FROM emiproce,emiprede,emidepen  
		 WHERE emiprede.cod_procedimiento = emiproce.cod_procedimiento
		   and emidepen.no_poliza   = emiprede.no_poliza
		   and emidepen.no_unidad   = emiprede.no_unidad
		   and emidepen.cod_cliente = emiprede.cod_cliente
		   and emidepen.no_poliza   = _no_poliza
		   and emidepen.no_unidad   = _no_unidad
		   AND emidepen.cod_cliente = _cod_reclamante
		
		if _cont = 5 then
			exit foreach;
		end if	
		return _exclusion with resume;
		let _cont = _cont + 1;
	end foreach	
end if
END PROCEDURE
                                                                                                                                   
