
   DROP procedure sp_jean13;
   CREATE procedure sp_jean13()
   RETURNING char(20) as poliza,
   char(10) as cod_contratante,
   CHAR(50) as n_contratante,
   char(50) as email_contr,
   char(5)  as cod_corredor,
   char(50) as n_corredor,
   char(50) as email_corredor;
   
   --char(20),char(5),char(10),CHAR(50),char(30),char(10),CHAR(50),char(30),char(5),char(50),char(30);
     
    DEFINE _no_poliza,_cod_asegurado	 	CHAR(10);
    DEFINE _no_documento    CHAR(20);
    DEFINE _cod_agente,_no_unidad      CHAR(5);
	define _cod_contratante char(10);
    DEFINE _n_contratante,_n_agente   	CHAR(50);
	define _n_asegurado varchar(100);
	define _email_corredor,_email_asegurado,_email_contr              char(50);

foreach
	select no_documento
	  into _no_documento
	  from tmp_asegurado
	
	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	
    foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		exit foreach;
    end foreach
	
	select email_reclamo,
	       nombre
	  into _email_corredor,
	       _n_agente
	  from agtagent
	 where cod_agente = _cod_agente; 

	select nombre,e_mail
	  into _n_contratante,_email_contr
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	return _no_documento,_cod_contratante,_n_contratante,_email_contr,_cod_agente,_n_agente,_email_corredor with resume;

end foreach
{foreach
	select no_documento,
	       no_unidad,
		   cod_asegurado,
		   nombre_asegurado
	  into _no_documento,
	       _no_unidad,
		   _cod_asegurado,
		   _n_asegurado
	  from tmp_asegurado
	
	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	
    foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		exit foreach;
    end foreach
	
	select email_reclamo,
	       nombre
	  into _email_corredor,
	       _n_agente
	  from agtagent
	 where cod_agente = _cod_agente; 

	select e_mail
	  into _email_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	select nombre,e_mail
	  into _n_contratante,_email_contr
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	return _no_documento,_no_unidad,_cod_asegurado,_n_asegurado,_email_asegurado,_cod_contratante,_n_contratante,_email_contr,_cod_agente,_n_agente,_email_corredor with resume;

end foreach}
END PROCEDURE;
