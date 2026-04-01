-- Creado    : 17/05/2013 - Autor: Federico Coronado.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec099;
CREATE PROCEDURE "informix".sp_rec099(a_no_documento CHAR(20), a_cod_reclamante CHAR(10), a_estado smallint)
RETURNING   smallint,
			char(15),
			char(50),
			char(50),
			char(200);
		
DEFINE v_no_poliza          CHAR(10);
DEFINE v_cod_corredor       CHAR(10);
DEFINE v_nombre_reclamante  char(50);
DEFINE v_nombre             char(50);
DEFINE v_autorizado         char(15);
DEFINE v_email_personas     char(200);
DEFINE v_email_cliente      char(50);
DEFINE v_return             smallint;


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec099.trc";      
--TRACE ON;                                                                     

LET v_no_poliza = sp_sis21(a_no_documento);
	
foreach
	select cod_agente
	  into v_cod_corredor
	  from emipoagt
	 where no_poliza = v_no_poliza

	select nombre, email_personas
	  into   v_nombre, v_email_personas
	  from  agtagent
	 where cod_agente = v_cod_corredor;

	select nombre, e_mail 
	  into v_nombre_reclamante, v_email_cliente
	  from cliclien
	 where cod_cliente = a_cod_reclamante;
	
	if a_estado = 1 then
		let v_autorizado = "Autorizado";
	else
		let v_autorizado = "No Autorizado";
	end if

	if trim(v_email_personas) = '' and trim(v_email_cliente) = '' then
		let v_return = 0;
	else
		let v_return = 1;
		if trim(v_email_cliente) <> "" and trim(v_email_personas) <> "" then
			let v_email_personas = trim(v_email_personas)||';'||trim(v_email_cliente);
		elif trim(v_email_personas) = "" and trim(v_email_cliente) <> "" then
			let v_email_personas = v_email_cliente;
		end if
	end if
end foreach	
RETURN v_return,v_autorizado,v_nombre,v_nombre_reclamante,v_email_personas;
end procedure