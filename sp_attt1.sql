-- procedimiento para buscar el contratante para ser arreglado

-- Creado    : 17/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_attt1;

CREATE PROCEDURE "informix".sp_attt1()
returning char(20),		 
		  char(10),	     
		  varchar(100),
		  varchar(100),
		  varchar(30),
		  char(1),
		  smallint,
		  char(10);


define _no_documento	char(20);
define _no_poliza	    char(10);
define _cod_contratante char(10);
define _nombre,_aseg_primer_ape   char(100);
define _cedula,_no_motor  varchar(30);
define _tipo_p char(1);
define _no_unidad char(5);
define _placa char(10);
define _pasaporte smallint;


SET ISOLATION TO DIRTY READ;

foreach

  SELECT no_documento
   	INTO _no_documento
    FROM a  

  let _no_poliza = sp_sis21(_no_documento);

  select cod_contratante
    into _cod_contratante
	from emipomae
   where no_poliza = _no_poliza;

  select nombre,aseg_primer_ape,cedula,tipo_persona,pasaporte
    into _nombre,_aseg_primer_ape,_cedula,_tipo_p,_pasaporte
	from cliclien
   where cod_cliente = _cod_contratante;

  if _pasaporte = 1 then
  else
	continue foreach;
  end if

  select count(*)
    into _pasaporte
	from emipouni
   where no_poliza = _no_poliza;

 { IF _pasaporte = 1 then

	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza = _no_poliza;

	 select no_motor
	   into _no_motor
	   from emiauto
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad;

	select placa
	  into _placa
	  from emivehic
	 where no_motor = _no_motor;

  else
    let _placa = '';
  end if }
    let _placa = '';
      
   return _no_documento,
          _cod_contratante,
		  _nombre,
		  _aseg_primer_ape,
		  _cedula,
		  _tipo_p,
		  _pasaporte,
		  _placa
		  with resume;
end foreach

END PROCEDURE
