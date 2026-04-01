-- POLIZAS VIGENTES 
--

DROP procedure sp_jean15;
CREATE procedure sp_jean15(a_fecha date)
RETURNING char(20) as poliza,
          char(3)  as cod_subramo,
		  CHAR(50) as n_subramo,
		  char(5)  as cod_producto,
		  char(50) as n_producto,
		  char(10) as cod_asegurado,
		  char(50) as n_asegurado,
		  char(10) as cod_contratante,
		  char(50) as n_contratante,
		  char(10) as cod_corredor,
		  char(50) as n_corredor,
		  char(50) as email_asegurado,
		  char(50) as email_corredor;

DEFINE _no_poliza,_cod_contratante,_cod_agente	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _n_subramo,_n_producto,_n_carnet,_n_contratante,_n_corredor,_n_asegurado  	CHAR(50);
DEFINE _cod_producto,_cod_asegurado    char(10);
define v_filtros        varchar(255);
define _no_unidad       char(5);
define _cod_subramo,_cod_carnet     char(3);
define _e_mail_aseg,_email_corredor      char(50);

CALL sp_pro03("001","001",a_fecha,"018;") RETURNING v_filtros;

foreach
	select no_poliza,
	       no_documento,
		   cod_subramo,
		   cod_contratante,
		   cod_agente
	  into _no_poliza,
	       _no_documento,
		   _cod_subramo,
		   _cod_contratante,
		   _cod_agente
	  from temp_perfil
	 where seleccionado = 1
	   and cod_subramo not in('012')
	   
	select nombre
	  into _n_subramo
	  from prdsubra
	 where cod_ramo = '018'
       and cod_subramo = _cod_subramo;
	   
	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;
	
	select nombre,
	       e_mail
	  into _n_corredor,
	       _email_corredor
	  from agtagent
	 where cod_agente = _cod_agente;
	
	   
	foreach
		select cod_producto,
		       cod_asegurado
	      into _cod_producto,
		       _cod_asegurado
 	      from emipouni 
		 where no_poliza = _no_poliza
		   and activo = 1
		 
		select nombre,
		       e_mail
		  into _n_asegurado,
		       _e_mail_aseg
	      from cliclien
	     where cod_cliente = _cod_asegurado;
		
		select nombre,
		       cod_carnet
		  into _n_producto,
		       _cod_carnet
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select nombre
		  into _n_carnet
		  from emicarnet
		 where cod_carnet = _cod_carnet; 
		 
		return _no_documento,_cod_subramo,_n_subramo,_cod_producto,_n_producto,_cod_asegurado,_n_asegurado,_cod_contratante,_n_contratante,
               _cod_agente,_n_corredor,_e_mail_aseg,_email_corredor	with resume;
	end foreach	
		 
end foreach
END PROCEDURE;
