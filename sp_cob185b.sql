-- Procedimiento para generar la informacion de los no cobros en el rutero.
--																					   
-- Creado    : 24/11/2005 - Autor: Lic. Armando Moreno								   
-- Modificado: 24/11/2005 - Autor: Lic. Armando Moreno								   
-- Modificado: 27/05/2011 - Autor: Roman Gordon
--																					   
-- SIS v.2.0 - DEIVID, S.A.															   
																					   
DROP PROCEDURE sp_cob185b;															   
															  						   
CREATE PROCEDURE "informix".sp_cob185b()					  
	   RETURNING	char(8),	--_user_added,   
	   				char(10),	--_id_cliente,   
	   				char(50),	--_nombre_motivo,
	   				char(3),	--_cod_cobrador,
	   				char(50),	--_email,
	   				char(50),	--_nom_cliente,
	   				char(50),	--_rutero,
	   				char(50),	--_zona,
	   				char(50),	--_no_documento
	   				char(100),		  
					dec(16,2);	--_apagar

define _user_added		char(8);							  
define _agente			char(100);							  
define _nombre_motivo	char(50);
define _nom_cliente		char(50);
define _nom_div_cob		char(50);
define _rutero			char(50);
define _email			char(50);							  
define _zona			char(50);
define _no_documento	char(20);
define _no_poliza		char(10);							  
define _id_cliente		char(10);
define _cod_agente		char(5);
define _cod_cobrador	char(3);
define _cod_zona		char(3);
define _leasing			smallint;
define _flag			smallint;
define _apagar			dec(16,2);
define _cod_div_cob		char(1);

--set debug file to "sp_cob185b.trc"; 
--trace on;

BEGIN

foreach			 

	select user_added,    
		   cod_pagador,
		   descripcion,
		   cod_cobrador
	  into _user_added,   
		   _id_cliente,   
		   _nombre_motivo,
		   _cod_cobrador
	  from cdmcorre

	let _email			= '';
	let _nom_cliente	= '';
	let _rutero			= '';
	let _zona			= '';
	let _no_documento	= '';
	let _agente			= '';
	let _apagar 		= 0;

	if _user_added is null then
		let _user_added = '';
	end if

	if _id_cliente is null then
		let _id_cliente = '';
	end if

	if _nombre_motivo is null then
		let _nombre_motivo = '';
	end if

	if _cod_cobrador is null then
	   	let _cod_cobrador = '';
	end if
	 
	
	select e_mail
	  into _email
	  from insuser
	 where usuario = _user_added;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _id_cliente;

	select nombre
	  into _rutero
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;


	foreach
		select no_documento,
			   a_pagar
		  into _no_documento,
			   _apagar
		  from cdmcorrd
		 where cod_pagador = _id_cliente
		
		call sp_sis21(_no_documento) returning _no_poliza;

		call sp_cob116(_no_poliza) returning _cod_agente,   
											 _agente,      
											 _cod_zona,
											 _zona,
											 _leasing,
											 _cod_div_cob,
											 _nom_div_cob;
											 					   
		return _user_added,   
			   _id_cliente,   
			   _nombre_motivo,
			   _cod_cobrador,
			   _email,
			   _nom_cliente,
			   _rutero,
			   _zona,
			   _no_documento,
			   _agente,
			   _apagar with resume;
	end foreach
end foreach
END
END PROCEDURE
