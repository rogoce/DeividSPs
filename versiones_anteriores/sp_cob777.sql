-- Procedimiento Marca fecha de suspension para los Cese Automatico de Avisos de Cancelacion.
-- Creado     : 21/10/2019  -- Autor: Henry Giron.	
-- execute procedure sp_cob777('01657')
-- SIS v.2.0 -- DEIVID, S.A.

DROP procedure sp_cob777;
 CREATE procedure "informix".sp_cob777(a_no_aviso char(10))
   RETURNING CHAR(20),
             char(100),
			 char(50),
             char(100),
			 char(50),
			 date,
			 date,
			 char(10),
			 date,
             char(10),			 
			 char(10),
			 integer,date;

BEGIN
	define _mensaje			  varchar(100);
	define _excepcion		  smallint;
	define _error_isam		  integer;
	define _error			  integer;
    DEFINE v_no_documento     CHAR(20);
    DEFINE v_descripcion   	  CHAR(50);
    DEFINE v_desc_asegurado   CHAR(100);
	DEFINE _email             CHAR(100);
	DEFINE v_acreedor		  CHAR(50);
	define _fecha_proceso     date;
	define _fecha_vence       date;
    define _fecha_actual	  date;
	define _fecha_envio       date;
	define _fecha_suspension  date;
    define _cubierto_hasta	  date;
	define _no_aviso		  char(10);
	define _no_poliza		  char(10);
	define _renglon           integer;

	SET ISOLATION TO DIRTY READ;
    let _fecha_actual = sp_sis26();
	
FOREACH
	select a.no_aviso,a.no_documento,a.no_poliza,a.renglon,
	       a.nombre_cliente,
		   a.nombre_agente,
		   a.nombre_acreedor,
		   a.fecha_proceso,
		   a.fecha_vence,
		   p.email,
		   date(p.fecha_envio)
	  into _no_aviso,v_no_documento,_no_poliza,_renglon,
           v_desc_asegurado,
           v_descripcion,
		   v_acreedor,
		   _fecha_proceso,
		   _fecha_vence,
           _email,
		   _fecha_envio
	  from parmailcomp t, parmailsend p, avisocanc a
	 where t.mail_secuencia = p.secuencia
	   and t.no_documento = a.no_documento
	   and t.no_remesa    = a.no_aviso
	   and t.renglon = a.renglon
	   and p.cod_tipo    = '00010'
	   --and t.no_remesa   = a_no_aviso
       and year(p.date_added) = year(_fecha_actual)
       and month(p.date_added) = 9 --month(_fecha_actual)
   --  and t.no_remesa = '01657'
       and a.ejecuto = 1	   
	   
	   call sp_dev06(v_no_documento,_fecha_envio) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;
	   let _fecha_suspension = _fecha_suspension + 30 units day;
		if _error <> 0 then
			let _mensaje = _mensaje || ' ' || trim(v_no_documento);
			return '',
             _mensaje,
			 '',
             '',
			 '',
			 null,
			 null,
			 '',
			 null,
             '',			 
			 '',
			 _error,null;  
			 
		end if	   

		  RETURN v_no_documento,
				 v_desc_asegurado,
				 v_descripcion,
				 _email,
				 v_acreedor,
				 _fecha_proceso,
				 _fecha_vence,
				 a_no_aviso,
				 _fecha_suspension,_no_aviso,_no_poliza,_renglon,_fecha_envio
				 WITH RESUME;


end foreach

END

END PROCEDURE;
