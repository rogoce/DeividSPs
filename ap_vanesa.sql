-- Procedimiento que verifica si cambia el evento de un reclamo desde el paso de digitalizacion en WF

-- Creado    : 04/04/2014 - Autor: Amado Perez  

drop procedure ap_vanesa;

create procedure ap_vanesa() 
returning CHAR(20), VARCHAR(100);

define _no_reclamo              CHAR(10);
define _cod_taller              CHAR(10);
define _numrecla                CHAR(20);
define _taller                  VARCHAR(100);



--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;


set isolation to dirty read;

foreach

  SELECT numrecla    
    INTO _numrecla         
    FROM tmp_vane  
 
  LET _no_reclamo = NULL;
     
  SELECT no_reclamo
    INTO _no_reclamo
	FROM recrcmae
   WHERE numrecla = _numrecla;

  LET _cod_taller = NULL;

  foreach
	select cod_cliente
	  into _cod_taller
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and cod_tipopago = '002'
	   and actualizado = 1
	exit foreach; 
  end foreach

  LET _taller = NULL;

  SELECT nombre
    INTO _taller
	FROM cliclien
   WHERE cod_cliente = _cod_taller;

	return _numrecla,          
		   _taller with resume;
end foreach    


end procedure