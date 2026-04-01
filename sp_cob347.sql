
--Creado por Armando Moreno
--Fecha 12/01/2015

DROP procedure sp_cob347;

 CREATE procedure "informix".sp_cob347(a_no_aviso char(10))
   RETURNING CHAR(20),
             char(100),
			 char(50),
             char(100),
			 char(50),
			 date,
			 date,
			 char(10);  

BEGIN

    DEFINE v_no_documento     CHAR(20);
    DEFINE v_descripcion   	  CHAR(50);
    DEFINE v_desc_asegurado   CHAR(100);
	DEFINE _email             CHAR(100);
	DEFINE v_acreedor		  CHAR(50);
	define _fecha_proceso     date;
	define _fecha_vence       date;

	SET ISOLATION TO DIRTY READ;

FOREACH
	select a.no_documento,
	       a.nombre_cliente,
		   a.nombre_agente,
		   a.nombre_acreedor,
		   a.fecha_proceso,
		   a.fecha_vence,
		   p.email
	  into v_no_documento,
           v_desc_asegurado,
           v_descripcion,
		   v_acreedor,
		   _fecha_proceso,
		   _fecha_vence,
           _email		   
	  from parmailcomp t, parmailsend p, avisocanc a
	 where t.mail_secuencia = p.secuencia
	   and t.no_documento = a.no_documento
	   and t.no_remesa    = a.no_aviso
	   and t.renglon = a.renglon
	   and p.cod_tipo    = '00010'
	   and t.no_remesa   = a_no_aviso

		  RETURN v_no_documento,
				 v_desc_asegurado,
				 v_descripcion,
				 _email,
				 v_acreedor,
				 _fecha_proceso,
				 _fecha_vence,
				 a_no_aviso
				 WITH RESUME;


end foreach

END

END PROCEDURE;
