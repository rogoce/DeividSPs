-- Procedimiento busca las perdidas de arrendadora economica
-- 
-- Creado     : 09/10/2013 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud41;

create procedure "informix".sp_aud41()
       returning char(20), varchar(100), varchar(50), varchar(50), varchar(50), smallint, char(10), dec(16,2), dec(16,2);




define _no_reclamo	    char(10);
define _suma_asegurada	dec(16,2);
define _perdida     	dec(16,2);
define _fecha_documento	date;
define _cod_asegurado	char(10);
define _no_motor		char(30);
define _numrecla		char(20);
define _cod_evento      char(3);
define _causa           varchar(50);
define _nom_asegurado  	varchar(100);
define _cod_marca 		  char(5);
define _cod_modelo 		  char(5);
define _ano_auto		  smallint;
define _marca			  varchar(50);
define _modelo			  varchar(50);
define _pagado     	    dec(16,2);
define _variacion       dec(16,2);
define _placa           char(10);

set isolation to dirty read;

foreach with hold
 select fecha_documento,
	    cod_asegurado,
		no_motor,
		cod_evento,
		numrecla,
		no_reclamo,
		suma_asegurada
   into _fecha_documento,
        _cod_asegurado,
	    _no_motor,
		_cod_evento,
		_numrecla,
		_no_reclamo,
		_suma_asegurada
   from recrcmae
   WHERE ( recrcmae.fecha_documento >= '01/01/2010' ) AND  
         ( recrcmae.fecha_documento <= '31/12/2012' ) AND  
         ( recrcmae.numrecla[1,2] in ( '02','20' ) ) AND 
         ( recrcmae.perd_total = 1 ) AND
         (recrcmae.cod_reclamante in ( '56219','61754','35166','49192','78659','36880' ) OR  
         recrcmae.cod_asegurado in ( '56219','61754','35166','49192','78659','36880') )   
  
	select nombre 
	  into _nom_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
 
	select nombre
	  into _causa
	  from recevent
	 where cod_evento = _cod_evento;

    select cod_marca, cod_modelo, ano_auto, placa
	  into _cod_marca, _cod_modelo, _ano_auto, _placa
	  from emivehic
	 where no_motor = _no_motor;

    SELECT nombre
	  INTO _marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre
	  INTO _modelo
	  FROM emimodel
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo; 

    LET _pagado = 0;
    LET _variacion = 0;
	   
	--Pago , ded, salv etc para sacar incurrido

	    SELECT SUM(monto)
		  INTO _pagado
		  FROM rectrmae
		 WHERE no_reclamo   = _no_reclamo
		   AND cod_tipotran IN ("004", "005", "006", "007")
	       AND periodo[1,4] >= '2010'
	       AND periodo[1,4] <= '2012'
		   AND actualizado  = 1;

     IF _pagado IS NULL THEN
    	LET _pagado = 0;
	 END IF
	--Variacion

		 select	SUM(variacion)
		   into _variacion
		   from rectrmae
		  WHERE no_reclamo   = _no_reclamo
		    AND periodo[1,4] >= '2010'
	        AND periodo[1,4] <= '2012'
		    AND actualizado  = 1;

     IF _variacion IS NULL THEN
    	LET _variacion = 0;
	 END IF

   return _numrecla, _nom_asegurado, _causa, _marca, _modelo, _ano_auto, _placa, _suma_asegurada, _pagado + _variacion with resume; 


end foreach

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure